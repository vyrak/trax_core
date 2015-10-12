require 'spec_helper'

describe ::Trax::Core::Types::Struct do
  before(:all) do
    module MyFakeStructNamespace
      extend ::Trax::Core::Definitions

      struct :Locale do
        string :en, :default => ""
        string :da, :default => ""
        string :ca, :default => "eh"

        struct :territories do
          string :en, :default => "US"
        end
      end
    end
  end

  subject { "::MyFakeStructNamespace::Locale".constantize.new(:en => "something") }

  it { expect(subject).to have_key("en") }
  it { expect(subject.en).to eq "something" }
  it { expect(subject.da).to eq "" }
  it { expect(subject.ca).to eq "eh" }
  it { expect(subject.territories.en).to eq "US" }

  context "unknown value" do
    subject { "::MyFakeStructNamespace::Locale".constantize.new(:blah => "something") }
    it { expect(subject).to_not respond_to(:blah) }
    it { expect(subject.en).to eq "" }
  end
end
