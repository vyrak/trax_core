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
end
