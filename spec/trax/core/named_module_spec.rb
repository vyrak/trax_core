require 'spec_helper'

describe ::Trax::Core::NamedModule do
  let(:fake_module_name) { "FakeNamespace::Ecommerce" }
  subject { Object.const_get(fake_module_name) }

  it { expect(subject).to respond_to(:price) }
  it { expect(subject).to respond_to(:shipping) }
  it { expect(subject.some_method).to eq "blah" }

  context "includes" do
    let(:fake_module_name) { "FakeNamespace::ThingWithIncludes" }
    it { expect(subject::BASE_PRICE).to eq "0.00" }
  end


  context "includes" do
    let(:fake_module_name) { "FakeNamespace::ThingWithIncludes" }
    it { expect(subject::BASE_PRICE).to eq "0.00" }
  end

  context "variables" do
    let(:fake_module_name) { "FakeNamespace::ThingWithAttributes" }

    it { expect(subject.default_setting_for_something).to eq "anything" }
  end
end
