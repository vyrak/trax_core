module Klasses
  class MyBaseClass
    # include ::Trax::Core::AbstractMethods

    # abstract_method :some_instance_method
    # abstract_class_method :some_class_method

    include ::Trax::Core::AbstractMethods

    abstract_method :some_instance_method

    def self.inherited(subclass)
      after_inherited do

        _abstract_instance_methods.each do |method_name|
          puts subclass.instance_methods.include?(method_name)

          # raise ::Trax::Core::Errors::AbstractInstanceMethodNotDefined.new(
          #   :klass => subclass.name,
          #   :method_name => method_name
          # ) unless subclass.instance_methods.include?(method_name)
        end

        binding.pry
      end

      # super(subclass)


    end

    # def self.inherited(child)
    #   super(child)
    #   # binding.pry
    #   after_inherited do
    #     # puts "I WAS INHERITED"
    #     # binding.pry
    #     #
    #
    #     puts "AFTER INHERITED CALLBACK"
    #   end
    # end
  end

  class Something < MyBaseClass
    puts "I AM SOMETHING"

    puts "END OF DEFINITION"

    def some_instance_method
      puts "DO SOMETHING"
    end
  end
end
