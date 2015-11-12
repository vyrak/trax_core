require 'spec_helper'

describe ::Trax::Core::Types::Struct do
  before(:all) do
    module MyFakeStructNamespace
      extend ::Trax::Core::Definitions

      struct :Location do
        string :region
        enum :continent do
          define :north_america, 1
          define :south_america, 2
          define :Europe,        3
          define :Asia,          4
        end
      end

      struct :Locale do
        string :en, :default => ""
        string :da, :default => ""
        string :ca, :default => "eh"

        struct :territories do
          string :en, :default => "US"
        end

        array :locations, :of => "MyFakeStructNamespace::Location"

        json :phone_formats
        json :date_formats, :default => {:en_US => "%m-%d-%y"}
      end
    end
  end

  subject { "::MyFakeStructNamespace::Locale".constantize.new(:en => "something") }

  it { expect(subject).to have_key("en") }
  it { expect(subject.en).to eq "something" }
  it { expect(subject.da).to eq "" }
  it { expect(subject.ca).to eq "eh" }

  it { expect(subject.territories.en).to eq "US" }

  it { expect(subject.phone_formats).to eq({}) }
  it { expect(subject.date_formats).to eq('en_US' => "%m-%d-%y") }

  context "unknown value" do
    subject { "::MyFakeStructNamespace::Locale".constantize.new(:blah => "something") }
    it { expect(subject).to_not respond_to(:blah) }
    it { expect(subject.en).to eq "" }
  end

  context "with json property" do
    let(:locale) { :en_GB }
    let(:date_format) { "%d/%m/%Y" }
    let(:definition){ "::MyFakeStructNamespace::Locale".constantize.new(:date_formats => {locale => date_format}) }
    subject { definition.date_formats }

    it { expect(subject[locale.to_s]).to eq date_format }
    it { expect(subject[locale.to_sym]).to eq date_format }
  end

  context "with array_of property" do
    let(:definition) { "::MyFakeStructNamespace::Locale".constantize.new(:locations => [{:continent => :asia}]) }

    subject { definition }
    it { expect(definition.locations.first.continent.to_i).to eq(4) }

    context "casts to empty array" do
      let(:definition) { "::MyFakeStructNamespace::Locale".constantize.new }
      it { expect(definition.locations.length).to eq 0 }
      it { expect(definition.locations).to_not eq nil }
    end
  end
end
