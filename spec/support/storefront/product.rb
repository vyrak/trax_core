module Storefront
  class Product
    include ::FakeNamespace::Mixable

    mixins :priceable => { :default_starting_price => 9.99 }
  end
end
