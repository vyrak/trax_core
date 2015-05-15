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
      subject do
        {:name => "something", :price => 40 }
      end

      it do
        result = subject.tap(&{:price => :cost})
        result[:cost].should eq 40
      end

      context "transforming of values" do
        subject { {:name => "something", :price => 40 } }

        it do
          result = subject.tap(&{
            :name => :name,
            :price => { :sale_price => ->(val){ val / 2 } }
          })

          result[:sale_price].should eq 20
        end
      end
    end

    context "non hash object" do
      subject { ::OpenStruct.new({:name => "something", :price => 40}) }

      it do
        subject.as(&{:price => :cost})[:cost].should eq 40
      end

      context "transforming of values" do
        subject { ::OpenStruct.new({:name => "something", :price => 40 }) }

        it do
          result = subject.as(&{
            :name => :name,
            :price => { :sale_price => ->(val){ val / 2 } }
          })

          result[:sale_price].should eq 20
        end
      end
    end
  end
end
