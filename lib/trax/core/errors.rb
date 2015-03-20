module Trax
  module Core
    module Errors
      # A simple inheritable error class
      # Because Im sick of defining in every project a base error class
      # and I dont believe arguments to throw error should be order dependent
      # Example:
      #
      #  class AbstractInstanceMethodNotDefined < ::Trax::Core::Errors::Base
      #    attr_accessor :method_name, :klass
      #
      #    message {
      #      "Abstract instance method, #{method_name} not defined for #{klass}"
      #    }
      #  end
      #
      #  raise ::AbstractInstanceMethodNotDefined.new(:method_name => "my_method", :klass => self.class.name)

      class Base < StandardError
        class_attribute :_message

        def self.message(&block)
          self._message = block
        end

        def initialize(_attributes = {})
          _attributes.each_pair {|k,v| instance_variable_set("@#{k}", v) }

          super(message)
        end

        def message
          self.instance_eval(&self.class._message)
        end
      end

    end
  end
end
