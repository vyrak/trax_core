module Storefront
  class Product
    include ::FakeNamespace::Mixable

    binding.pry

    # binding.pry

    mixins :priceable => { :default_starting_price => 9.99 }
  end
end
