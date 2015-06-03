require 'spec_helper'

describe ::Class do
  describe ".superclasses_until" do
    it {
      ::InheritanceChainNamespace::D.superclasses_until(::InheritanceChainNamespace::A).should eq [
        ::InheritanceChainNamespace::B,
        ::InheritanceChainNamespace::C
      ]
    }
  end
end
