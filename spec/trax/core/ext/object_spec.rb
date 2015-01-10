require 'spec_helper'

describe ::Object do
  before do
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
end
