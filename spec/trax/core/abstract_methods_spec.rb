require 'spec_helper'

describe ::Trax::Core::AbstractMethods do



  # MyBaseClass

  subject {
    ::Klasses::MyBaseClass
  }

  # its(:_abstract_instance_methods) { should include(:some_instance_method) }
  # its(:_abstract_class_methods) { should include(:some_class_method) }

  # context "subclass not defining an abstract instance method" do
  #   it "throws error" do
  #
  #     class MyChildClass < Klasses::MyBaseClass
  #
  #     end
  #
  #
  #     # binding.pry
  #
  #     expect {
  #       class MyChildClass < Klasses::MyBaseClass
  #
  #
  #
  #       end
  #     }.to raise_error(::Trax::Core::Errors::AbstractInstanceMethodNotDefined)
  #     # binding.pry
  #   end
  # end

  context "subclass defining an instance method" do

    class MyOtherChildClass < Klasses::MyBaseClass
      def do_something
        puts "I AM DOING SOMETHING"
      end
      def some_instance_method; end
    end

    it "does not throw error" do
      expect {
        class MyOtherChildClass < Klasses::MyBaseClass
          def do_something
            puts "I AM DOING SOMETHING"
          end
          def some_instance_method; end
        end
      }.not_to raise_error(::Trax::Core::Errors::AbstractInstanceMethodNotDefined)
    end
  end
end
