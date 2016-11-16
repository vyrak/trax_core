require 'spec_helper'

describe ::Class do
  describe ".superclasses_until" do
    it do
      expect(::InheritanceChainNamespace::D.superclasses_until(::InheritanceChainNamespace::A)).to eq [
        ::InheritanceChainNamespace::B,
        ::InheritanceChainNamespace::C
      ]
    end
  end

  describe ".detect_in_chain" do
    before(:all) do
      class FakeParentKlass; @something = "anything" end
      class FakeChildKlass < FakeParentKlass; end
      class FakeGrandchildKlass < FakeChildKlass; end
      class FakeGreatGrandchildKlass; @something = "somethingelse" end
    end

    subject { FakeChildKlass }

    context "has ivar directly defined" do
      subject { FakeParentKlass }

      it { expect(subject.instance_variable_get(:"@something")).to eq "anything" }
    end

    context "child class without instance variable defined" do
      subject { FakeChildKlass }

      it { expect(subject.instance_variable_get(:"@something")).to be_nil }
      it { expect(subject.detect_in_chain{ instance_variable_get(:"@something") }).to eq "anything" }
    end

    context "grandchild class without instance variable defined" do
      subject { FakeGrandchildKlass }

      it { expect(subject.instance_variable_get(:"@something")).to be_nil }
      it { expect(subject.detect_in_chain{ instance_variable_get(:"@something") }).to eq "anything" }
    end

    context "great grandchild class with instance variable overridden" do
      subject { FakeGreatGrandchildKlass }

      it { expect(subject.instance_variable_get(:"@something")).to eq "somethingelse" }
      it { expect(subject.detect_in_chain{ instance_variable_get(:"@something") }).to eq "somethingelse" }
    end
  end
end
