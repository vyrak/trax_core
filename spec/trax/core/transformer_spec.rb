require 'spec_helper'

describe ::Trax::Core::Transformer do
  let(:payload) do
    {
      "id": "027b0d40-016c-40ea-8925-a076fa640992",
      "name": "Uber",
      "legalName": "Uber, Inc.",
      "domain": "uber.com",
      "domainAliases": ['uber.co'],
      "url": "http://uber.com",
      "site": {
        "url": "http://uber.com",
        "title": nil,
        "h1": nil,
        "metaDescription": nil,
        "metaAuthor": nil,
        "phoneNumbers": ["+1 877-223-8023"],
        "emailAddresses": ["ALEX@CLEARBIT.CO", "team@clearbit.com", "sales@clearbit.com", "support@clearbit.com", "alex@clearbit.com", "harlow@clearbit.com", "jobs+engineer@clearbit.com", "jobs+sales@clearbit.com"]
      },
      "tags": [
        "Transportation",
        "Design",
        "SEO",
        "Automotive",
        "Real Time",
        "Limousines",
        "Public Transportation",
        "Transport"
      ],
      "description": "Uber is a mobile app connecting passengers with drivers for hire.",
      "foundedDate": "2009-03-01",
      "location": "1455 Market Street, San Francisco, CA 94103, USA",
      "timeZone": "America/Los_Angeles",
      "utcOffset": -8,
      "geo": {
        "streetNumber": "1455",
        "streetName": "Market Street",
        "subPremise": nil,
        "city": "San Francisco",
        "state": "California",
        "stateCode": "CA",
        "postalCode": "94103",
        "country": "United States",
        "countryCode": "US",
        "lat": 37.7752315,
        "lng": -122.4175567
      },
      "metrics": {
        "raised": 1502450000,
        "employees": 1000,
        "googleRank": 7,
        "alexaUsRank": 2467,
        "alexaGlobalRank": 2319,
        "marketCap": nil,
        "annualRevenue": 20000
      },
      "logo": "https://dqus23xyrtg1i.cloudfront.net/v1/logos/027b0d40-016c-40ea-8925-a076fa640992",
      "facebook": {
        "handle": "uber.IND"
      },
      "linkedin": {
        "handle": "company/uber.com"
      },
      "category": {
        "sector": "Industrials",
        "industryGroup": "Transportation",
        "industry": "Road & Rail",
        "subIndustry": "Ground Transportation"
      },
      "twitter": {
        "handle": "uber",
        "id": 19103481,
        "bio": "Everyone's Private Driver. Question, concern or praise? Tweet at your local community manager here: https://t.co/EUiTjLk0xj",
        "followers": 176582,
        "following": 330,
        "location": "Global",
        "site": "http://t.co/PtMbwFTeQA",
        "avatar": "https://pbs.twimg.com/profile_images/378800000762572812/91ea09a6535666e18ca3c56f731f67ef_normal.jpeg"
      },
      "angellist": {
        "id": 19163,
        "handle": "uber",
        "description": "Request a car from any mobile phone via text message, iPhone and Android apps. Within minutes, a professional driver in a sleek black car will arrive curbside. Automatically charged to your credit card on file, tip included.",
        "followers": 2650,
        "blogUrl": "http://blog.uber.com/"
      },
      "crunchbase": {
        "handle": "uber"
      },
      "emailProvider": false,
      "type": "private",
      "tech": [
        "google_analytics",
        "double_click",
        "mixpanel",
        "optimizely",
        "typekit_by_adobe",
        "nginx",
        "google_apps"
      ],
      "somethingElse": "somethingElseValue",
      "some_value_transform": 10,
      "some_value_to_times_by": 2,
      "some_value": 30,
      "stats": {
        "number_of_widgets": 20,
        "number_of_employees": 40
      }
    }.with_indifferent_access
  end

  before do
    class PayloadTransformer < ::Trax::Core::Transformer
      property "name"
      property "something", :default => ->(v) { "anything" }
      property "some_non_proc_default", :default => 5
      property "legal_name", :from => "legalName"
      property "stats", :default => ->(v) { {} }
      property "stats/number_of_widgets", :default => ->(v) { 40 }
      property "stats/google_rank", :from => "metrics/googleRank"
      property "some_value"
      property "some_value_to_times_by"
      property "some_value_transform", :with => ->(val, instance) {
        val * instance["some_value_to_times_by"]
      }
    end
  end

  subject {
    PayloadTransformer.new(payload)
  }

  context "class methods" do
    describe ".from_property_mapping" do
      it { expect(PayloadTransformer.from_property_mapping).to have_key("legalName") }
    end
  end

  context "properties" do
    it {
      expect(subject.class.properties["stats/number_of_widgets"].is_nested?).to eq true
    }
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
      context "mapping from source hash" do
        it {
          expect(subject["stats"]["number_of_employees"]).to eq 40
        }
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

    it {
      expect(subject.to_hash).to_not have_key("stats/number_of_widgets")
    }
  end
end
