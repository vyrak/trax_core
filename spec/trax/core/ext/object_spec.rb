require 'spec_helper'

describe ::Object do
  before(:all) do
    class SomeFakeClass < OpenStruct
    end
  end

  subject do
    SomeFakeClass
  end

  describe ".try_chain" do
    it "wraps multiple calls to try and calls try on return value" do
      subject.try_chain(:name, :underscore).should eq "some_fake_class"
    end

    it "handles return if nil is in chain" do
      subject.try_chain(:name, :somefakemethod).should be_nil
    end

    it "handles instances of class" do
      SomeFakeClass.new.try_chain(:class, :name, :underscore).should eq "some_fake_class"
    end
  end

  describe ".set_fully_qualified_constant" do
    it "sets a fully qualified constant" do
      result = Object.set_fully_qualified_constant("SomeFakeClass::SomeFakeNestedClass", Class.new)
      result.name.should eq "SomeFakeClass::SomeFakeNestedClass"
    end

    it "raises error if no valid namespace to set constant upon is passed" do
      expect{Object.set_fully_qualified_constant("SomeFakeNestedClass", Class.new)}.to raise_error(StandardError)
    end
  end

  describe ".remove_instance_variables" do
    it "reset instance variables by symbol names" do
      obj = SomeFakeClass.new
      obj.instance_variable_set(:@someivar, "anything")
      obj.reset_instance_variables(:someivar)
      obj.instance_variable_get(:@someivar).should be nil
    end
  end
end
