module FakeNamespace
  module Priceable
    extend ::FakeNamespace::Mixin

    included do
      class_attribute :default_starting_price
      attr_accessor :starting_price
    end

    # mixed_in do |options|
    #   self.default_starting_price = options[:default_starting_price]
    # end

    def starting_price
      @starting_price || default_starting_price
    end
  end
end
