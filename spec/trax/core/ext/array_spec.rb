require 'spec_helper'

describe Array do
  subject { ["one", "two", "three", "one", ["two"]]}

  it { subject.flat_compact_uniq!.should eq ["one", "two", "three"] }
  it "modifies array in place" do
    test_subject = subject.flat_compact_uniq!
    test_subject.object_id.should eq subject.object_id
  end
end
