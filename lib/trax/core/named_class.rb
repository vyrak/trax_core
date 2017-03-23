module Trax
  module Core
    class NamedClass
      include ::Trax::Core::SilenceWarnings

      def self.new(_name, _parent_klass=Object, **options, &block)
        klass = silence_warnings {
          ::Object.set_fully_qualified_constant(_name, ::Class.new(_parent_klass) {
            define_singleton_method(:name) { _name }
          })
        }

        klass.class_attribute :definition_blocks
        klass.definition_blocks = _parent_klass.try(:definition_blocks) ? _parent_klass.definition_blocks.clone : ::Set.new
        klass.definition_blocks << block

        options.each_pair do |k,v|
          klass.class_attribute k
          klass.__send__("#{k}=", v)
        end unless options.blank?

        klass.class_eval(&block) if block_given?

        klass
      end
    end
  end
end
