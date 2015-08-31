require 'spec_helper'

describe ::Trax::Core::NamedClass do
  let(:fake_klass_name) { "FakeNamespace::Something" }
  subject { Object.const_get(fake_klass_name) }

  it { expect(subject.superclass).to eq ::String }
  it { expect(subject.name).to eq fake_klass_name }

  context "Does not inherit from another class" do
    let(:fake_klass_name) { "FakeNamespace::SomeBlankClass" }

    it { expect(subject.name).to eq fake_klass_name }
    it { expect(subject.superclass).to eq ::Object }
  end

  context "Created class can reference its given class name when defining behavior" do
    let(:fake_klass_name) { "FakeNamespace::Dmx" }

    it { expect(subject.whats_my_name).to eq "fake_namespace/dmx" }
  end

  context "Created class accepts an options hash which defines its own attribute set at creation" do
    let(:fake_klass_name) { "FakeNamespace::ClassWithAttributes" }

    it { expect(subject.length).to eq 20 }
    it { expect(subject.height).to eq 15 }
  end
end
