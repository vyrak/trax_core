require 'spec_helper'

describe ::Trax::Core::Types::ValueObject do
  subject { described_class.new(nil) }
  it{ is_expected.to be_nil }
end
