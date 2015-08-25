require 'spec_helper'

describe URI do
  subject{ URI.parse("http://www.google.com") }

  it { expect(subject.join("something", "else")).to eq URI("http://www.google.com/something/else") }
end
