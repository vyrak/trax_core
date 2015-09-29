require 'spec_helper'

describe ::Trax::Core::Definitions do
  subject { ::Defs }

  context "enum" do
    let(:test_subject) { subject::Category.new(1) }

    it { expect(test_subject).to be_a(::Trax::Core::Types::Enum) }
    it { expect(test_subject.name).to eq "Defs::Category::Default" }
  end

  context "struct" do
    it { expect(subject::ProductAttributes.new).to be_a(::Trax::Core::Types::Struct) }
  end

  context "inheritance" do
    it { expect(subject::ProductAttributes.new).to_not have_key(:size) }
    it { expect(subject::ShoesAttributes.new).to have_key(:size) }
    it { expect(subject::ShoesAttributes.new).to have_key(:price) }
    it { expect(subject::ShoesAttributes.new(:size => :mens_8).size.to_i).to eq 1 }
  end
end
