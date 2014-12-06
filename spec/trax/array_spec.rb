require 'spec_helper'

describe ::Array do
  subject do
    [
      {:name => "something", :price => 40},
      {:name => "else", :price => 50}
    ]
  end

  describe "#to_proc" do
    it{
      subject.map(&[:name, :price]).map(&:last).sum.should eq 90
    }
  end
end
