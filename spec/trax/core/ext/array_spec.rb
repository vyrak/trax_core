require 'spec_helper'

describe Array do
  subject { ["one", "two", "three", "one", ["two"]]}

  it { expect(subject.flat_compact_uniq!).to eq ["one", "two", "three"] }
  it "modifies array in place" do
    test_subject = subject.flat_compact_uniq!
    expect(test_subject.object_id).to eq subject.object_id
  end
end
