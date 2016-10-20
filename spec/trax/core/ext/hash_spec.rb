require 'spec_helper'

describe Hash do
  subject { {:one => :two, :three => :four } }

  describe "#assert_required_keys" do
    it { expect { subject.assert_required_keys(:five) }.to raise_error(ArgumentError) }
    it { expect { subject.assert_required_keys(:one) }.not_to raise_error }
  end
end
