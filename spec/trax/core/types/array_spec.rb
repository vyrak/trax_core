require 'spec_helper'

describe ::Trax::Core::Types::Array do
  before(:all) do
    module AnotherFakeStructNamespace
      extend ::Trax::Core::Definitions
      struct :Widget do
        integer :height, :default => 0
        integer :width, :default => 0
      end
    end
  end

  subject { ::Trax::Core::Types::Array.of(::AnotherFakeStructNamespace::Widget) }

  context ".of" do
    let(:test_subject) { subject.new({:width => 1}) }
    it { test_subject[0].width.should eq 1 }
    it { test_subject[0].height.should eq 0 }
  end

  context "ArrayOf" do
    subject { ::Trax::Core::Types::ArrayOf[::AnotherFakeStructNamespace::Widget] }
    let(:test_subject) { subject.new({:width => 1}) }
    it { test_subject[0].width.should eq 1 }
    it { test_subject[0].height.should eq 0 }
  end
end
