require 'spec_helper'

describe ::Module do
  subject { Trax::Core }

  describe ".module_attribute" do
    before(:all) do
      Trax.module_attribute(:some_fake_hash) do
        {}
      end
    end

    it { expect(Trax.some_fake_hash).to be_a(Hash) }
  end

  describe ".recursively_define_namespaced_class" do
    context "when class namespace does not exist at global module level" do
      before do
        Trax.recursively_define_namespaced_class("Somefake::Thing")
      end

      it { Trax::Somefake::Thing.class == Object }
    end

    context "when class namespace does exist at global module level" do
      before do
        Trax.recursively_define_namespaced_class("Core::FakeKlass", Hash)
      end

      it { expect(Trax::Core::FakeKlass.superclass).to eq Hash }
    end
  end

  describe ".configuration_for" do
    before do
      ::Trax.recursively_define_namespaced_class("Core::FakeNamespace", Module)

      ::Trax::Core::FakeNamespace.configuration_for(Trax::Core::FakeNamespace) do
        option :something, :required => true
      end
    end

    subject{ ::Trax::Core::FakeNamespace::Configuration }

    its(:superclass) { is_expected.to eq ::Trax::Core::Configuration }

    it "sets up configuration options" do
      ::Trax::Core::FakeNamespace.configure do |config|
        config.something = 'anything'
      end

      expect(::Trax::Core::FakeNamespace.config.something).to eq 'anything'
    end
  end

  describe ".configuration_options" do
    before do
      ::Trax.recursively_define_namespaced_class("Core::SomeFakeKlass", Hash)

      ::Trax::Core::SomeFakeKlass.define_configuration_options do
        option :base_url, :required => true
        option :subdomains, :default => []
      end
    end

    it "blows up if required and not set" do
      expect {
        ::Trax::Core::SomeFakeKlass.configure do |config|
          config.subdomains = [:blah, :blah]
        end

      }.to raise_error(Trax::Core::Errors::ConfigurationError)
    end

    it "sets defaults" do
      ::Trax.recursively_define_namespaced_class("Core::YetAnotherFakeClass", Hash)

      Trax::Core::YetAnotherFakeClass.define_configuration_options do
        option :base_url
        option :allowed_ips, :default => [ '192.231.1234' ]
      end

      ::Trax::Core::YetAnotherFakeClass.configure do |config|
        config.base_url = 'somewhere'
      end

      expect(::Trax::Core::YetAnotherFakeClass.config.allowed_ips[0]).to eq '192.231.1234'
    end
  end
end
