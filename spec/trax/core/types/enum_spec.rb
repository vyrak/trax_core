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
end
