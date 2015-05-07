module FakeNamespace
  module Priceable
    extend ::FakeNamespace::Mixin

    included do
      class_attribute :default_starting_price
    end

    on_mixed_in do |options|
      self.default_starting_price = options[:default_starting_price]
    end

    def some_instance_method
      "some_instance_method_return"
    end

    def starting_price
      @starting_price || self.class.default_starting_price
    end

    module ClassMethods
      def some_class_method
        "some_class_method_return"
      end
    end
  end
end
