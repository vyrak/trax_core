module Trax
  module Core
    class NamedClass
      def self.new(_name, _parent_klass=nil, **options, &block)
        klass = ::Object.set_fully_qualified_constant(_name, (_parent_klass ? ::Class.new(_parent_klass) : Class.new do
          define_singleton_method(:name) { _name }

          options.each_pair do |k,v|
            self.class.class_attribute k
            self.__send__("#{k}=", v)
          end
        end))

        klass.instance_eval(&block) if block_given?

        klass
      end
    end
  end
end
