require 'hashie/extensions/coercion'
require 'hashie/extensions/indifferent_access'
require 'hashie/extensions/dash/indifferent_access'

module Trax
  module Core
    module Types
      class Struct < ::Hashie::Dash
        include ::Hashie::Extensions::Dash::IndifferentAccess
        include ::Hashie::Extensions::Coercion
        include ::Hashie::Extensions::IgnoreUndeclared
        include ::Hashie::Extensions::Dash::PropertyTranslation

        # note that we must explicitly set default or blank values for all properties.
        # It defeats the whole purpose of being a 'struct'
        # if we fail to do so, and it makes our data far more error prone
        DEFAULT_VALUES_FOR_PROPERTY_TYPES = {
          :boolean_property => nil,
          :string_property  => "",
          :struct_property  => {},
          :enum_property    => nil,
          :integer_property => nil
        }.with_indifferent_access.freeze

        def self.initialize_clone(source)
          puts "CLONING"
          instance_variable_set("@fields_module", source.fields_module)
          super
        end


        def self.fields_module
          @fields_module ||= begin
            module_name = "#{self.name}::Fields"
            ::Trax::Core::NamedModule.new(module_name, ::Trax::Core::Fields)
            # binding.pry
            # mod = if const_defined?(module_name)
            #         const_get(module_name)
            #       else
            #        ::Trax::Core::NamedModule.new(module_name, ::Trax::Core::Fields) unless const_defined?(module_name)
            #       end
            #
            # mod
          end
        end

        def self.fields
          fields_module
        end

        def self.boolean_property(name, *args, **options, &block)
          name = name.is_a?(Symbol) ? name.to_s : name
          klass_name = "#{fields_module.name.underscore}/#{name}".camelize
          options[:default] = options.key?(:default) ? options[:default] : DEFAULT_VALUES_FOR_PROPERTY_TYPES[__method__]
          property(name.to_sym, *args, **options)
          coerce_key(name.to_sym, ->(value) { !!value })
        end

        def self.integer_property(name, *args, **options, &block)
          name = name.is_a?(Symbol) ? name.to_s : name
          options[:default] = options.key?(:default) ? options[:default] : DEFAULT_VALUES_FOR_PROPERTY_TYPES[__method__]
          property(name.to_sym, *args, **options)
          coerce_key(name.to_sym, Integer)
        end

        def self.string_property(name, *args, **options, &block)
          name = name.is_a?(Symbol) ? name.to_s : name

          klass_name = "#{fields_module.name.underscore}/#{name}".camelize

          attribute_klass = if options.key?(:extend)
            _klass_prototype = options[:extend].constantize.clone
            _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => self, &block)
            _klass
          else
            ::Trax::Core::NamedClass.new(klass_name, ::Trax::Core::Types::String, :parent_definition => self, &block)
          end

          options[:default] = options.key?(:default) ? options[:default] : DEFAULT_VALUES_FOR_PROPERTY_TYPES[__method__]
          property(name.to_sym, *args, **options)
          coerce_key(name.to_sym, attribute_klass)
        end

        def self.struct_property(name, *args, **options, &block)
          name = name.is_a?(Symbol) ? name.to_s : name
          klass_name = "#{fields_module.name.underscore}/#{name}".camelize

          attribute_klass = if options.key?(:extend)
            _klass_prototype = options[:extend].constantize.clone
            _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => self, &block)
            _klass
          else
            ::Trax::Core::NamedClass.new(klass_name, ::Trax::Core::Types::Struct, :parent_definition => self, &block)
          end

          options[:default] = options.key?(:default) ? options[:default] : DEFAULT_VALUES_FOR_PROPERTY_TYPES[__method__]
          property(name.to_sym, *args, **options)
          coerce_key(name.to_sym, attribute_klass)
        end

        def self.enum_property(name, *args, **options, &block)
          name = name.is_a?(Symbol) ? name.to_s : name
          klass_name = "#{fields_module.name.underscore}/#{name}".camelize

          attribute_klass = build_attribute_klass_for_type(:enum, name, *args, **options, &block)

          # attribute_klass = if options.key?(:extend)
          #   _klass_prototype = options[:extend].constantize.clone
          #   _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => self, &block)
          #   _klass
          # else
          #   ::Trax::Core::NamedClass.new(klass_name, ::Trax::Core::Types::Enum, :parent_definition => self, &block)
          # end

          options[:default] = options.key?(:default) ? options[:default] : DEFAULT_VALUES_FOR_PROPERTY_TYPES[__method__]
          property(name.to_sym, *args, **options)
          coerce_key(name.to_sym, attribute_klass)
        end

        def self.to_schema
          ::Trax::Core::Definition.new(
            :source => self.name,
            :name => self.name.demodulize.underscore,
            :type => :struct,
            :fields => self.fields_module.to_schema
          )
        end

        def self.type; :struct end;

        def to_serializable_hash
          _serializable_hash = to_hash

          self.class.fields_module.enums.keys.each do |attribute_name|
            _serializable_hash[attribute_name] = _serializable_hash[attribute_name].try(:to_i)
          end if self.class.fields_module.enums.keys.any?

          _serializable_hash
        end

        class << self
          alias :boolean :boolean_property
          alias :enum :enum_property
          alias :integer :integer_property
          alias :struct :struct_property
          alias :string :string_property
        end

        def value
          self
        end

        private

        def self.build_attribute_class_for_type(type_name, *args, **options, &block)
          klass_name = "#{fields_module.name.underscore}/#{name}".camelize

          attribute_klass = if options.key?(:extend)
            _klass_prototype = options[:extend].constantize.clone
            _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => self, &block)
            _klass
          else
            ::Trax::Core::NamedClass.new(klass_name, "::Trax::Core::Types::#{type_name.to_s.classify}".constantize, :parent_definition => self, &block)
          end

          attribute_klass

          # options[:default] = options.key?(:default) ? options[:default] : DEFAULT_VALUES_FOR_PROPERTY_TYPES[__method__]
          # property(name.to_sym, *args, **options)
          # coerce_key(name.to_sym, attribute_klass)
        end
      end
    end
  end
end
