require 'spec_helper'

describe ::Trax::Core do
  it {
    expect{ Trax::Core::EagerAutoloadNamespace }.to_not raise_error
  }
end
