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
          :array   => [],
          :boolean => nil,
          :float   => 0.0,
          :string  => "",
          :struct  => {},
          :enum    => nil,
          :integer => nil
        }.with_indifferent_access.freeze

        def self.fields_module
          @fields_module ||= begin
            module_name = "#{self.name}::Fields"
            mod = ::Trax::Core::NamedModule.new(module_name, ::Trax::Core::Fields.clone)
            mod.include(superclass.fields) if superclass.instance_variable_defined?("@fields_module")
            mod
          end
        end

        def self.fields
          fields_module
        end

        def self.array_property(name, *args, of:false, **options, &block)
          of_object = of && of.is_a?(::String) ? of.safe_constantize : of
          coercer = of_object ? ::Array[of_object] : ::Array
          define_attribute_class_for_type(:array, name, *args, :coerce => coercer, **options, &block)
        end

        def self.boolean_property(name, *args, **options, &block)
          define_attribute_class_for_type(:boolean, name, *args, :coerce => ->(value){!!value}, **options, &block)
        end

        def self.enum_property(name, *args, **options, &block)
          define_attribute_class_for_type(:enum, name, *args, :coerce => true, **options, &block)
        end

        def self.float_property(name, *args, **options, &block)
          define_attribute_class_for_type(:float, name, *args, :coerce => ::Float, **options, &block)
        end

        def self.integer_property(name, *args, **options, &block)
          define_attribute_class_for_type(:integer, name, *args, :coerce => ::Integer, **options, &block)
        end

        def self.string_property(name, *args, **options, &block)
          define_attribute_class_for_type(:string, name, *args, :coerce => ::String, **options, &block)
        end

        def self.struct_property(name, *args, **options, &block)
          define_attribute_class_for_type(:struct, name, *args, :coerce => true, **options, &block)
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
          alias :array :array_property
          alias :boolean :boolean_property
          alias :enum :enum_property
          alias :float :float_property
          alias :integer :integer_property
          alias :struct :struct_property
          alias :string :string_property
        end

        def value
          self
        end

        private

        #By default, strings/int/bool wont get cast to value objects
        #mainly for the sake of performance/avoid unneccessary object allocation
        def self.define_attribute_class_for_type(type_name, property_name, *args, coerce:false, **options, &block)
          name = name.is_a?(Symbol) ? name.to_s : name
          klass_name = "#{fields_module.name.underscore}/#{property_name}".camelize

          attribute_klass = if options.key?(:extend)
            _klass_prototype = options[:extend].constantize
            _klass = ::Trax::Core::NamedClass.new(klass_name, _klass_prototype, :parent_definition => self, &block)
            _klass
          else
            ::Trax::Core::NamedClass.new(klass_name, "::Trax::Core::Types::#{type_name.to_s.classify}".constantize, :parent_definition => self, &block)
          end

          options[:default] = options.key?(:default) ? options[:default] : DEFAULT_VALUES_FOR_PROPERTY_TYPES[type_name]
          property(property_name.to_sym, *args, **options)

          if coerce.is_a?(::Proc)
            coerce_key(property_name.to_sym, &coerce)
          elsif coerce.is_a?(::Array)
            coerce_key(property_name.to_sym, coerce)
          elsif [ ::Integer, ::Float, ::String ].include?(coerce)
            coerce_key(property_name.to_sym, coerce)
          elsif coerce
            coerce_key(property_name.to_sym, attribute_klass)
          end
        end
      end
    end
  end
end
