require 'spec_helper'

describe ::Trax::Core::Types::Set do
  before(:all) do
    module AnotherFakeStructNamespace
      extend ::Trax::Core::Definitions

      struct :Widget do
        integer :height, :default => 0
        integer :width, :default => 0
      end
    end
  end

  subject { ::Trax::Core::Types::Set.of(::AnotherFakeStructNamespace::Widget) }

  context ".of" do
    let(:test_subject) { subject.new({:width => 1}) }
    it { expect(test_subject.to_a[0].width).to eq 1 }
    it { expect(test_subject.to_a[0].height).to eq 0 }

    context "does not duplicate values" do
      it {
        test_subject << {:width => 2, :height => 2}
        expect(test_subject.to_a.length).to eq 2
      }

      it {
        test_subject << {}
        test_subject << {}
        expect(test_subject.to_a.last.width).to eq 0
      }
    end
  end
end
