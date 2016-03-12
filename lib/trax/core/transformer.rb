module Trax
  module Core
    class Transformer < SimpleDelegator
      attr_reader :input, :parent

      def self.inherited(subklass)
        subklass.class_attribute :properties
        subklass.properties = {}.with_indifferent_access
        subklass.class_attribute :after_initialize_callbacks
        subklass.after_initialize_callbacks = ::Set.new
        subklass.class_attribute :after_transform_callbacks
        subklass.after_transform_callbacks = ::Set.new
      end

      def self.after_initialize(&block)
        after_initialize_callbacks << block
      end

      def self.after_transform(&block)
        after_transform_callbacks << block
      end

      def self.properties_with_default_values
        @properties_with_default_values ||= properties.values.select{ |prop| prop.try(:default) }
      end

      def self.nested_properties
        @nested_properties ||= properties.values.select{|prop| prop.is_nested? }
      end

      def self.is_nested?
        !!self.try(:parent_definition)
      end

      def self.from_parent?
        false
      end

      def self.property(_property_name, **options, &block)
        options[:parent_definition] = self
        options[:property_name] = _property_name
        options[:with] = block if block_given?
        transformer_klass_name = "#{name}::#{_property_name.camelize}"
        transformer_klass = ::Trax::Core::NamedClass.new(transformer_klass_name, Property, **options)
        self.properties[_property_name] = transformer_klass
      end

      def self.transformer(_property_name, **options, &block)
        options[:parent_definition] = self
        options[:property_name] = _property_name
        options[:default] = ->(){ {}.with_indifferent_access } unless options.key?(:default)
        options[:with] = block if block_given?
        transformer_klass_name = "#{name}::#{_property_name.camelize}"
        transformer_klass = ::Trax::Core::NamedClass.new(transformer_klass_name, Transformer, **options, &block)
        self.properties[_property_name] = transformer_klass
      end

      def self.nested(*args, **options, &block)
        transformer(*args, **options, &block)
      end

      def self.fetch_property_from_object(_property, obj)
        if _property.include?('/')
          property_chain = _property.split('/')
          obj.dig(*property_chain)
        else
          obj[_property]
        end
      end

      def initialize(obj={}, parent=nil)
        @input = obj.dup
        @output = {}.with_indifferent_access
        @parent = parent if parent

        initialize_output_properties
        initialize_default_values
        run_after_initialize_callbacks if run_after_initialize_callbacks?
        run_after_transform_callbacks if run_after_transform_callbacks?
      end

      def [](_property)
        if _property.include?('/')
          property_chain = _property.split('/')
          self.dig(*property_chain)
        else
          super(_property)
        end
      end

      def key?(_property)
        if _property.include?('/')
          property_chain = _property.split('/')
          !!self.dig(*property_chain)
        else
          super(_property)
        end
      end

      def has_parent?
        !!parent
      end

      def parent_key?(k)
        return false unless has_parent?

        parent.key?(k)
      end

      def __getobj__
        @output
      end

      private

      def initialize_default_values
        self.class.properties_with_default_values.each do |prop|
          unless @output.key?(prop.property_name)
            if prop.default.is_a?(Proc)
              @output[prop.property_name] = prop.default.arity > 0 ? prop.default.call(@output) : prop.default.call
            else
              @output[prop.property_name] = prop.default
            end
          end
        end
      end

      def initialize_output_properties
        self.class.properties.each_pair do |k,property_klass|
          if @input.key?(property_klass.property_name)
            value = @input[property_klass.property_name]
            @output[property_klass.property_name] = property_klass.new(value, self)
          elsif @input.key?(property_klass.try(:from))
            value = @input[property_klass.from]
            @output[property_klass.property_name] = property_klass.new(value, self)
          elsif property_klass.from_parent?
            value = self.class.fetch_property_from_object(property_klass.from_parent, self.parent.input)
            @output[property_klass.property_name] = property_klass.new(value, self)
          elsif property_klass.ancestors.include?(::Trax::Core::Transformer)
            value = if property_klass.default.is_a?(Proc)
              property_klass.default.arity > 0 ? property_klass.default.call(self) : property_klass.default.call
            else
              property_klass.default
            end

            @output[property_klass.property_name] = property_klass.new(value, self)
          end
        end
      end

      #will not transform output based on callback result
      def run_after_initialize_callbacks
        self.class.after_initialize_callbacks.each do |callback|
          @output.instance_eval(&callback)
        end
      end

      def run_after_initialize_callbacks?
        self.class.after_initialize_callbacks.any?
      end

      #will transform output with return of each callback
      def run_after_transform_callbacks
        self.class.after_transform_callbacks.each do |callback|
          @output = @output.instance_exec(self, &callback)
        end
      end

      def run_after_transform_callbacks?
        self.class.after_transform_callbacks.any?
      end
    end

    class Property < SimpleDelegator
      def self.is_nested?
        @is_nested ||= !!self.try(:parent_definition)
      end

      def self.is_translated?
        @is_translated ||= !!self.try(:from)
      end

      def self.from_parent?
        @from_parent ||= !!try(:from_parent)
      end

      def initialize(value, transformer)
        @value = value

        if self.class.try(:with)
          @value = self.class.with.arity > 1 ? self.class.with.call(@value, transformer) : self.class.with.call(@value)
        end
      end

      def __getobj__
        @value
      end
    end
  end
end
