module Trax
  module Core
    class Transformer < SimpleDelegator
      attr_reader :input

      def self.inherited(subklass)
        subklass.class_attribute :properties
        subklass.properties = {}.with_indifferent_access
      end

      def self.properties_with_default_values
        @properties_with_default_values ||= properties.values.select{ |prop| prop.try(:default) }
      end

      def self.properties_with_from
        @properties_with_from ||= properties.values.select{ |prop| prop.try(:from) }
      end

      def self.from_property_mapping
        @from_property_mapping ||= properties_with_from.each_with_object({}.with_indifferent_access) do |prop,result|
          result[prop.from] = prop
        end
      end

      def self.property(_property_name, **options, &block)
        options[:parent_definition] = self
        options[:property_name] = _property_name
        transformer_klass_name = "#{name}::#{_property_name.camelize}"
        transformer_klass = ::Trax::Core::NamedClass.new(transformer_klass_name, Property, **options, &block)
        self.properties[_property_name] = transformer_klass
      end

      # def [](k)
      #   if k.include?("/")
      #     self.dig(*k.split("/"))
      #   else
      #     self[k]
      #   end
      # end

      def initialize(obj)
        @input = obj.dup
        @output = {}.with_indifferent_access

        self.class.properties.each_pair do |k,property_klass|
          if @input.key?(property_klass.property_name)
            value = @input[property_klass.property_name]
            @output[property_klass.property_name] = property_klass.new(value, self)
          elsif @input.key?(property_klass.try(:from))
            value = @input[property_klass.from]
            @output[property_klass.property_name] = property_klass.new(value, self)
          end

          # if property_klass.is_nested?
          #   @output[property_klass.key] = @input.dig(*property_klass.key)
          # else
          #   if @input.key?(property_klass.property_name)
          #     value = @input[property_klass.property_name]
          #     @output[property_klass.property_name] = property_klass.new(value, self)
          #   elsif @input.key?(property_klass.try(:from))
          #     value = @input[property_klass.from]
          #     @output[property_klass.property_name] = property_klass.new(value, self)
          #   end
          # end
        end

        # @input.each_pair do |k,v|
        #   if self.class.from_property_mapping.key?(k)
        #     transformer = self.class.from_property_mapping[k]
        #     @output[transformer.property_name] = transformer.new(v, self)
        #   else
        #     @output[k] = self.class.properties[k].new(v, self) if self.class.properties.key?(k)
        #   end
        # end

        initialize_default_values
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
    end

    class Property < SimpleDelegator
      def self.is_nested?
        !!self.try(:parent_definition)
      end

      def self.is_translated?
        !!self.try(:from)
      end

      def self.key
        if is_nested?
          segs = property_name.split("/")
          if is_translated?
            translated_key_segs = property_name.from.split("/")

            if translated_key_segs.length > 1
              translated_key_segs.reverse.map{|seg|
                segs.pop
                segs << seg
              }
            end

            segs
          else
            segs
          end
        else
          property_name
        end
      end

      def self.nested_setter_key
        @nested_setter_key ||= begin
          _new_key = key.dup
          _new_key.pop
          _new_key
        end
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
