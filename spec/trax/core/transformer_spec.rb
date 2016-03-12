require 'spec_helper'

describe ::Trax::Core::Transformer do
  let(:payload) do
    {
      "name" => "Uber",
      "legalName" => "Uber, Inc.",
      "url" => "http =>//uber.com",
      "metrics" => {
        "raised" => 1502450000,
        "annualRevenue" => 20000
      },
      "somethingElse" => "somethingElseValue",
      "some_value_transform" => 10,
      "some_value_to_times_by" => 2,
      "some_value" => 30,
      "stats" => {
        "number_of_widgets" => 20,
        "number_of_employees" => 40
      }
    }.with_indifferent_access
  end

  before do
    class PayloadTransformer < ::Trax::Core::Transformer
      property "name"
      property "something", :default => ->(v) { "anything" }
      property "some_non_proc_default", :default => 5
      property "legal_name", :from => "legalName"

      property "some_value"
      property "some_value_to_times_by"
      property "some_value_transform", :default => ->(i){ 1 } do |value, instance|
        value * instance["some_value_to_times_by"]
      end

      transformer "stats" do
        property "number_of_employees"
        property "raised", :from_parent => "metrics/raised"
        property "google_rank", :from_parent => "metrics/googleRank"
      end

      transformer "website" do
        property "url", :from_parent => "url"
      end
    end
  end

  subject {
    PayloadTransformer.new(payload)
  }

  context "class methods" do
    describe ".transformer" do
      it {
        expect(subject.class.properties['stats'].is_nested?).to eq true
      }
    end
  end

  context "property mapping strategies" do
    it "property declration without options" do
      expect(subject["name"]).to eq "Uber"
    end

    context "property with default value" do
      it "value is a proc" do
        expect(subject["something"]).to eq "anything"
      end

      it "value is not a proc" do
        expect(subject["some_non_proc_default"]).to eq 5
      end
    end

    context "property key translated" do
      it {
        expect(subject["legal_name"]).to eq "Uber, Inc."
      }

      it "removes translated value from hash" do
        expect(subject.to_hash).to_not have_key("legalName")
      end
    end

    context "nested properties" do
      it "mapping from source hash" do
        expect(subject["stats"]["number_of_employees"]).to eq 40
      end

      it "mapping from parent nested property" do
        expect(subject["stats"]["raised"]).to eq payload["metrics"]["raised"]
      end

      it "brand new nested property" do
        expect(subject["website"]["url"]).to eq payload["url"]
      end
    end

    it {
      expect(subject["some_value"]).to eq 30
    }

    it {
      expect(subject["some_value_to_times_by"]).to eq 2
    }

    it {
      expect(subject["some_value_transform"]).to eq 20
    }
  end
end
