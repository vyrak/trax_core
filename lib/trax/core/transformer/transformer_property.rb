module Trax
  module Core
    class TransformerProperty < SimpleDelegator
      include ::Trax::Core::CommonTransformerMethods
      # def self.is_nested?
      #   return @is_nested if defined?(@is_nested)
      #   @is_nested = !!try(:parent_definition)
      # end
      #
      # def self.is_translated?
      #   return @is_translated if defined?(@is_translated)
      #   @is_translated = !!try(:from)
      # end
      #
      # def self.is_callable?
      #   return @is_callable if defined?(@is_callable)
      #   @is_callable = try(:with) && try(:with).is_a?(Proc)
      # end
      #
      # def self.has_default_value?
      #   return @has_default_value if defined?(@has_default_value)
      #   @has_default_value = !!try(:default)
      # end
      #
      # def self.from_parent?
      #   return @from_parent if defined?(@from_parent)
      #   @from_parent = !!try(:from_parent)
      # end
      #
      # def self.is_transformer?
      #   return @is_transformer if defined?(@is_transformer)
      #   @is_transformer = ancestors.include?(::Trax::Core::Transformer)
      # end
      #
      # def self.is_source_output?
      #   return @is_source_output if defined?(@is_source_output)
      #   @is_source_output = (try(:source) && try(:source) == :output) || false
      # end
      #
      # def self.is_source_input?
      #   return @is_source_input if defined?(@is_source_input)
      #   @is_source_input = !is_source_output?
      # end

      def self.input_key
        @input_key ||= self.try(:from) ? self.from : self.property_name
      end

      def self.input_key_chain
        @input_key_chain ||= input_key.split("/")
      end

      def self.output_key
        @output_key ||= self.try(:as) ? self.as : self.property_name
      end

      def initialize(transformer)
        if self.class.name == "PayloadTransformer::Stats::NumberOfEmployees"
          @transformer = transformer
          binding.pry
        end

        @transformer = transformer
        set_value
        transform_value if self.class.is_callable?
        set_default_value if set_default_value?
      end

      def nil?
        __getobj__.nil?
      end

      def __getobj__
        @value
      end

      def value
        @value
      end

      private

      def default_property_value
        if self.class.default.is_a?(Proc)
          self.class.default.arity > 0 ? self.class.default.call(@transformer) : self.class.default.call
        else
          self.class.default
        end
      end

      def transform_value
        @value = self.class.with.arity > 1 ? self.class.with.call(@value, @transformer) : self.class.with.call(@value)
      end

      def fetch_property_value
        target.dig(*self.class.input_key_chain)
      end

      def set_value
        @value = fetch_property_value
      end

      def set_default_value
        @default_value = default_property_value
      end

      def set_default_value?
        @value.nil? && self.class.has_default_value?
      end

      def target
        @target ||= if self.class.from_parent?

          @transformer.parent.input
        elsif !self.class.is_source_output?
          @transformer.input
        else
          @transformer.output
        end
      end
    end
  end
end
