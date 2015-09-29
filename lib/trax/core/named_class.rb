module Trax
  module Core
    class NamedClass
      def self.new(_name, _parent_klass=Object, **options, &block)

                # binding.pry if _name == "Kore::Types::SupportedLocalesExtended"
        # binding.pry
        # klass = ::Class.new(_parent_klass) do
        #
        #   binding.pry
        #   Object.set_fully_qualified_constant(_name, self)
        # end
        # klass = Object.qualified_const_set(_name, ::Class.new(_parent_klass){ define_singleton_method(:name) }) # => 1.618034
        klass = ::Object.set_fully_qualified_constant(_name, ::Class.new(_parent_klass){
          # Object.const_set(_name, self)

          define_singleton_method(:name) { |*args|
            super(*args)
            _name
          }
        })

        # klass = ::Class.allocate
        #
        # _method = klass.method(:initialize)
        #
        #
        # # _method.bind(klass)
        # ::Object.set_fully_qualified_constant(_name, klass)
        #         binding.pry
        # _method.call(_parent_klass)
        #
        #         binding.pry

        # ::Class.new(_parent_klass) {
        #
        # }

        # klass = Object.allocate()
        #
        # klass = ::Class.new(_parent_klass){
        #   Object.qualified_const_set(_name, self)
        #
        #   # define_singleton_method(:name) { |*args|
        #   #   super(*args)
        #   #   _name
        #   # }
        # }
        #
        binding.pry if _name == "Translator::Term::Fields::Translations"

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
