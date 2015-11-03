require 'spec_helper'

describe ::Trax::Core::HasDependencies do
  before(:all) do
    class MyFakeItem
      include ::Trax::Core::HasDependencies

      attr_reader :my_options

      def initialize(title, body, **options)
        @title = title
        @body = body
        @my_options = options
      end

      depends_on :organization, :pass_options_to_super => true
    end

    class MyFakeItemThatAcceptsNoOptions
      include ::Trax::Core::HasDependencies

      def initialize(title, body)
        @title = title
        @body = body
      end

      depends_on :organization, :pass_options_to_super => false
    end

    class MyFakeOrganization < Struct.new(:name)
    end
  end

  let(:organization) { MyFakeOrganization.new("whatever") }
  let(:my_fake_item) { MyFakeItem.new("mytitle", "mybody", :organization => organization, my_other_thing: 'whatever') }

  it "throws error if dependency not passed in" do
    expect{ MyFakeItem.new }.to raise_error(::Trax::Core::Errors::MissingRequiredDependency)
  end

  it "sets instance variables from dependency keys" do
    expect(my_fake_item.organization).to eq(organization)
  end

  it "allows options to be passed to it normally" do
    expect(my_fake_item.my_options[:my_other_thing]).to eq 'whatever'
  end

  it "rips out dependency keys from options when setting them" do
    expect(my_fake_item.my_options).to_not have_key('organization')
  end

  context "no options accepted by super intialize" do
    let(:my_fake_item) { ::MyFakeItemThatAcceptsNoOptions.new("mytitle", "mybody", :organization => organization) }

    it "sets instance variables from dependency keys" do
      expect(my_fake_item.organization).to eq(organization)
    end
  end
end
