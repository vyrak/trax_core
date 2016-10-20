require 'spec_helper'

describe ::Array do
  subject do
    [
      {:name => "something", :price => 40},
      {:name => "else", :price => 50}
    ]
  end

  describe "#to_proc" do
    it { expect(subject.map(&[:name, :price]).map(&:last).sum).to eq 90 }

    context "array of non hash objects" do
      subject {
        [
          OpenStruct.new({:name => "something", :price => 40}),
          OpenStruct.new({:name => "else", :price => 50})
        ]
      }

      it { expect(subject.map(&[:name, :price]).map(&[:price]).sum).to eq 90 }
    end
  end
end
