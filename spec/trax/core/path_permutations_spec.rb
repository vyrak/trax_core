require 'spec_helper'

describe ::Trax::Core::PathPermutations do
  let(:test_path_args) { ["a", "b", "c", "d"]}
  let(:expected_result) { ["a", "a/b", "a/b/c", "a/b/c/d"] }
  subject { described_class.new(*test_path_args) }

  it { expect(subject.length).to eq 4 }
  it { expect(subject).to eq expected_result }
end
