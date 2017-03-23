module Trax
  module Core
    module Definitions
      def self.extended(base)
        base.extend(Trax::Core::Fields)
      end

      def enum(klass_name, **options, &block)
        attribute_klass = if options.key?(:extends)
          _klass_prototype = options[:extends].constantize.clone

          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", ::Trax::Core::Types::Enum, :parent_definition => self) do
            _klass_prototype.definition_blocks.each{ |definition_block| self.instance_eval(&definition_block) }
            self.instance_eval(&block)
          end
        else
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", ::Trax::Core::Types::Enum, :parent_definition => self, :definition_block => block, &block)
        end

        attribute_klass
      end

      def struct(klass_name, **options, &block)
        attribute_klass = if options.key?(:extends)
          _klass_prototype = options[:extends].constantize.clone
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", _klass_prototype, :parent_definition => self, &block)
        else
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", ::Trax::Core::Types::Struct, :parent_definition => self, &block)
        end

        attribute_klass
      end
    end
  end
end
