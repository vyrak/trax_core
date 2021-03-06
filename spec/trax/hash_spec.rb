require 'spec_helper'

describe ::Hash do
  subject do
    [
      {:name => "something", :price => 40},
      {:name => "else", :price => 50 }
    ]
  end

  describe "#to_transformer" do
    it { expect(subject.map(&{:name => :name, :cost => :price }.to_transformer).map(&[:cost]).sum).to eq 90 }

    context "single hash" do
      subject do
        { :name => "something", :price => 40 }
      end

      it do
        result = subject.tap(&{:cost => :price}.to_transformer)
        expect(result[:cost]).to eq 40
      end

      context "transforming of values" do
        subject { { :name => "something", :price => 40 } }

        it do
          result = subject.tap(&{
            :name => :name,
            :sale_price => {:price => ->(val){ val / 2 } }
          }.to_transformer)

          expect(result[:sale_price]).to eq 20
        end
      end
    end

    context "non hash object" do
      subject { ::OpenStruct.new({:name => "something", :price => 40}) }

      it do
        expect(subject.as!({:cost => :price})[:cost]).to eq 40
      end

      context "transforming of values" do
        let(:original_subject) { ::OpenStruct.new({:name => "something", :price => 40 }) }

        subject do
          original_subject.as!({
            :name => :name,
            :sale_price => { :price => ->(val){ val / 2 } }
          })
        end

        it do
          expect(subject[:sale_price]).to eq 20
        end

        context "can transform into a new value while reusing value" do
          subject do
            original_subject.as!({
              :name => :name,
              :price => :price,
              :sale_price => { :price => ->(val){ val / 2 } }
            })
          end

          it { expect([subject[:sale_price], subject[:price]]).to eq [20, 40] }

          context "order dependency" do
            subject do
              original_subject.as!({
                :name => :name,
                :sale_price => { :price => ->(val){ val / 2 } },
                :price => :price
              })
            end

            it "should not matter" do
              expect([subject[:sale_price], subject[:price]]).to eq [20, 40]
            end
          end
        end

      end
    end
  end
end
