require 'spec_helper'

describe ::Hash do
  subject do
    [
      {:name => "something", :price => 40},
      {:name => "else", :price => 50 }
    ]
  end

  describe "#to_proc" do
    it{
      subject.map(&{:name => :name, :price => :cost}).map(&[:cost]).sum.should eq 90
    }

    context "single hash" do
      subject { {:name => "something", :price => 40} }
      it {
        result = subject.tap(&{:price => :cost})
        result[:cost].should eq 40
      }
    end

    context "non hash object" do
      subject { ::OpenStruct.new({:name => "something", :price => 40}) }
      it {
        subject.as(&{:price => :cost})[:cost].should eq 40
      }
    end
  end
end