module PricingExtension
  BASE_PRICE = "0.00"

  def price
    "9.99"
  end
end

module ShippingExtension
  def shipping
    "9.99"
  end
end

::Trax::Core::NamedModule.new("FakeNamespace::Ecommerce", PricingExtension, ShippingExtension) do
  def self.some_method
    "blah"
  end
end

::Trax::Core::NamedModule.new("FakeNamespace::ThingWithIncludes", :includes => [PricingExtension])

::Trax::Core::NamedModule.new("FakeNamespace::ThingWithAttributes", default_setting_for_something: 'anything') do

end
