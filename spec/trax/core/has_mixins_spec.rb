require 'spec_helper'

describe ::Trax::Core::HasMixins do
  before(:suite) do
    fake_namespace_module = Object.const_set("FakeNamespace", Module.new)

    fake_namespace_module.extend(::Trax::Core::HasMixins)
  end

  subject {
    "FakeNamespace".classify.constantize
  }

  it {
    binding.pry
    expect{

    subject.const_defined?("Mixins") }.to eq true }

end
