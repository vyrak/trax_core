require 'spec_helper'

describe ::Trax::Core::HasMixins do
  subject { FakeNamespace }

  it { expect(subject.const_defined?("Mixin")).to eq true }
  it { expect(subject.mixin_r-egistry).to be_a(Hash) }
  it { expect(subject::Mixin.mixin_namespace).to eq FakeNamespace }

  context "Mixin" do
    it {
      expect(::Storefront::Product.new.starting_price).to eq 9.99
    }
  end
end
