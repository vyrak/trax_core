require 'spec_helper'

describe ::Trax::Core::Errors do
  subject { ::Errors::SiteBrokenError }

  it { expect{ subject.new }.to raise_error(ArgumentError) }

  it do
    expect do
      raise subject.new(
        :request_url => 'http://www.somewhere.com',
        :request_id => 'asdasdsdad1231421'
      )
    end.to raise_error(subject)
  end

  it do
    subject.new(
      :request_url => 'http://www.somewhere.com',
      :request_id => 'asdasdsdad1231421'
    ).to_s.should include('http://www.somewhere.com')
  end
end
