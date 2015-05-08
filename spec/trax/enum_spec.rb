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
end
