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

    context "float" do
      it { expect(subject::ProductAttributes.new.price).to eq 9.99 }
      it { expect(subject::ProductAttributes.new(:price => 9).price).to eq 9.0 }
    end

    context "integer" do
      it { expect(subject::ProductAttributes.new.quantity_in_stock).to eq 0 }
      it { expect(subject::ProductAttributes.new(:quantity_in_stock => 9.19).quantity_in_stock).to eq 9 }
    end

    context "array" do
      it { expect(subject::ProductAttributes.new.categories).to be_a(Array) }
      context "it instantiates members into objects if provided" do
        it { expect(subject::ProductAttributes.new(:categories => [ :clothing ]).categories[0].to_i).to eq 2 }
        it { expect(subject::ProductAttributes.new(:categories => [ 2 ]).categories[0].to_s).to eq "clothing" }
      end
    end
  end

  context "inheritance" do
    it { expect(subject::ProductAttributes.new).to_not have_key(:size) }
    it { expect(subject::ShoesAttributes.new).to have_key(:size) }
    it { expect(subject::ShoesAttributes.new).to have_key(:price) }
    it { expect(subject::ShoesAttributes.new(:size => :mens_8).size.to_i).to eq 1 }
  end
end
