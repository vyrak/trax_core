require 'spec_helper'

describe ::Enumerable do
  let(:item1) { OpenStruct.new(:email => "whatever@whatever.com") }
  let(:item2) { OpenStruct.new(:email => "whoever@google.com") }
  subject { [ item1, item2] }

  it "#group_by_uniq" do
    array_grouped_by_uniq = subject.group_by_uniq(&:email)
    expect(array_grouped_by_uniq["whatever@whatever.com"]).to eq item1
  end
end
