require 'spec_helper'

describe ::Trax::Core::Errors do
  let(:error_attributes) do
    {
      :request_url => 'http://www.somewhere.com',
      :request_id => 'asdasdsdad1231421'
    }
  end

  subject { ::Errors::SiteBrokenError }

  it { expect { subject.new }.to raise_error(ArgumentError) }

  it { expect { raise subject.new(error_attributes) }.to raise_error(subject) }

  it { expect(subject.new(error_attributes).to_s).to include('http://www.somewhere.com') }
end
