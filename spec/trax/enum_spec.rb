require 'spec_helper'

describe ::Enum do
  subject do
    ::CategoryEnum
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
    subject { ::CategoryEnum.new(:clothing) }

    it { subject.choice.should eq :clothing }
    it { subject.choice.should eq 2 }
    it { expect(subject.next_value.to_sym).to eq :shoes }
    it { expect(subject.previous_value.to_sym).to eq :default }

    context "selection of values" do
      it { subject.select_next_value.should eq ::CategoryEnum.new(:shoes).choice }
    end
    context "value is last" do
      subject { ::CategoryEnum.new(:accessories) }
      it { subject.next_value?.should eq false }
      it { subject.previous_value?.should eq true }

      context "selection of value" do
        it { expect(subject.select_next_value).to eq ::CategoryEnum.new(:accessories) }
        it { expect(subject.select_previous_value).to eq ::CategoryEnum.new(:shoes) }
      end
    end
    # it { expect(subject.next_value.to_sym).to eq :shoes }
    # it { expect(subject.previous_value.to_sym).to eq :default }

  end
end
