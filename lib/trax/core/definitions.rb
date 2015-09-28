module Trax
  module Core
    module Definitions
      def self.extended(base)
        base.module_attribute(:_definitions) {
          ::Hashie::Mash.new
        }
      end

      def enum(klass_name, **options, &block)
        attribute_klass = if options.key?(:class_name)
          _klass = options[:class_name].constantize.clone
          _klass.class_eval(&block) if block_given?
          _klass
        else
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", ::Trax::Core::Types::Enum, :parent_definition => self, &block)
        end

        attribute_klass
      end

      def struct(klass_name, **options, &block)
        attribute_klass = if options.key?(:class_name)
          _klass = options[:class_name].constantize.clone
          _klass.class_eval(&block) if block_given?
          _klass
        else
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", ::Trax::Core::Types::Struct, :parent_definition => self, &block)
        end

        attribute_klass
      end

      def all
        @all ||= begin
          constants.map{|const_name| const_get(const_name) }.each_with_object(self._definitions) do |klass, result|
            result[klass.name.symbolize] = klass
          end
        end
      end

      def values
        all.values
      end

      def [](_name)
        const_get(_name.to_s.camelize)
      end
    end
  end
end
