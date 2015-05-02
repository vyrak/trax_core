require 'spec_helper'

describe ::Trax::Core::HasMixins do
  subject { FakeNamespace }

  it { expect(subject.const_defined?("Mixin")).to eq true }
  it { expect(subject.mixin_registry).to be_a(Hash) }
  it { expect(subject::Mixin.mixin_namespace).to eq FakeNamespace }

  context "Priceable Mixin" do
    it {
      expect(::Storefront::Product.new.starting_price).to eq 9.99
    }

    it "includes class methods" do
      expect(::Storefront::Product.some_class_method).to eq "some_class_method_return"
    end
  end
end
