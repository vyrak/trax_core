require 'spec_helper'

describe ::Trax::Core::Types::Enum do
  before(:all) do
    module MyFakeEnumNamespace
      extend ::Trax::Core::Definitions

      enum :Locale do
        define :en, 1
        define :da, 2
        define :ca, 3
      end

      enum :Category do
        define :default, 1, :display_name => "Default"
        define :clothing, 2, :display_name => "Clothing"
        define :shoes, 3, :display_name => "Shoes"
        define :accessories, 4, :display_name => "Accessories"
      end

      enum :ExtendedCategory, :extends => "MyFakeEnumNamespace::Category" do
        define :watches,    5
        define :sunglasses, 6
      end
    end
  end

  subject { "::MyFakeEnumNamespace::Locale".constantize.new(:en) }

  it { expect(subject.to_i).to eq 1 }

  context "integer value" do
    subject { "::MyFakeEnumNamespace::Locale".constantize.new(1) }

    it { expect(subject).to eq :en }
  end

  context "non existent value" do
    subject { "::MyFakeEnumNamespace::Locale".constantize.new(:blah) }

    it { expect(subject).to eq nil }
  end

  context "category enum" do
    subject do
      "::MyFakeEnumNamespace::Category".constantize
    end

    let(:expected_names) {  [:default, :clothing, :shoes, :accessories] }
    let(:expected_values) { [1,2,3,4] }

    describe ".key?" do
      it { subject.key?(:default).should eq true }
    end

    describe "[](val)" do
      it { subject[:default].to_i.should eq 1 }
    end

    describe "[](val)" do
      it { subject["default"].to_i.should eq 1 }
    end

    describe ".value?" do
      it { subject.value?(1).should eq true }
    end

    describe ".keys" do
      it { subject.keys.should eq [:default, :clothing, :shoes, :accessories] }
    end

    describe ".names" do
      it { subject.keys.should eq expected_names }
    end

    describe ".values" do
      it { subject.values.should eq expected_values }
    end

    context "duplicate enum name" do
      it { expect{subject.define_enum_value(:default, 6)}.to raise_error(::Trax::Core::Errors::DuplicateEnumValue) }
    end

    context "duplicate enum value" do
      it {expect{subject.define_enum_value(:newthing, 1)}.to raise_error(::Trax::Core::Errors::DuplicateEnumValue) }
    end

    context "InstanceMethods" do
      let(:described_object) do
        "::MyFakeEnumNamespace::Category".constantize
      end
      subject { described_object.new(:clothing) }

      it { subject.choice.should eq :clothing }
      it { subject.choice.should eq 2 }
      it { expect(subject.next_value.to_sym).to eq :shoes }
      it { expect(subject.previous_value.to_sym).to eq :default }

      context "selection of values" do
        it { subject.select_next_value.should eq described_object.new(:shoes).choice }
      end
      context "value is last" do
        subject { described_object.new(:accessories) }
        it { subject.next_value?.should eq false }
        it { subject.previous_value?.should eq true }

        context "selection of value" do
          it { expect(subject.select_next_value).to eq described_object.new(:accessories) }
          it { expect(subject.select_previous_value).to eq described_object.new(:shoes) }
        end
      end
    end
  end

  context "inheritance" do
    let(:described_object) do
      "::MyFakeEnumNamespace::ExtendedCategory".constantize
    end

    it { expect(described_object.names).to include(:watches)}
    it { expect(described_object.new(:clothing).to_i).to eq 2 }
    it { expect(described_object.new(:watches).to_i).to eq 5 }

    context "does not mutate original hash" do
      let(:described_object) do
        "::MyFakeEnumNamespace::Category".constantize
      end

      it { expect(described_object.names).to_not include(:watches)}
    end
  end

  context ".to_schema" do
    subject { "::MyFakeEnumNamespace::Category".constantize.new(2).to_schema }
    it { expect(subject[:attributes][:display_name]).to eq "Clothing" }
  end
end
