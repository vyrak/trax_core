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
      },
      "some_object" => {
        "thing" => 1,
        "warning_shot" => ""
      },
      "some_other_object" => {
        "some_value" => 2,
        "warning_shot" => ""
      },
      "some_unmapped_var" => 2,
      "warning_shot" => ""
    }.with_indifferent_access
  end

  before do
    class PayloadTransformer < ::Trax::Core::Transformer
      property "name"
      property "something", :default => ->(v) { "anything" }
      property "some_non_proc_default", :default => 5
      property "legal_name", :from => "legalName"
      property "warning_shot"

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

      before_transform do
        # noop
      end

      after_transform do
        # noop
      end

      before_transform do
        self.delete_if { |_, v| v.blank? }
      end

      transformer "some_object" do
        property "thing"
        property "warning_shot"

        before_transform do
          self.delete_if { |_, v| v.blank? }
        end

        after_transform do
          OpenStruct.new(self)
        end
      end

      transformer "some_other_object" do
        property "some_value"
        property "warning_shot"

        after_transform do |result|
          self['result'] = result['some_value'] * self.parent.input["some_unmapped_var"]
          OpenStruct.new(self)
        end
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

    context "callbacks" do
      context "before transform" do
        it "runs before transform callbacks which can mutate return result" do
          expect(subject).to_not have_key("warning_shot")
          expect(subject["some_object"]).to_not respond_to(:warning_shot)
          expect(subject["some_other_object"]).to respond_to(:warning_shot)
        end
      end

      context "after transform" do
        it "runs after transform callbacks which can mutate return result" do
          expect(subject["some_object"].thing).to eq 1
        end

        it "passes instance" do
          expect(subject["some_other_object"].result).to eq 4
        end

        it "wraps return value in class" do
          expect(subject["some_object"].__getobj__.is_a?(::OpenStruct)).to eq true
        end
      end
    end

    context "to_hash" do
      it "unwraps nested transformers" do
        expect(subject.to_hash["some_object"].is_a?(::OpenStruct)).to eq true
      end
    end

    context "to_recursive_hash" do
      it "unwraps nested transformers" do
        expect(subject.to_recursive_hash["some_object"].is_a?(::OpenStruct)).to eq true
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
