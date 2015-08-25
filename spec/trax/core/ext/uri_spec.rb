require 'spec_helper'

describe URI do
  subject{ URI.parse("http://www.google.com") }

  it { expect(subject.join("something", "else")).to eq URI("http://www.google.com/something/else") }

  describe "#join" do
    context "is passed a uri as arg" do
      it {
        expect(subject.join("one", "two", URI("three"))).to eq URI("http://www.google.com/one/two/three")
      }
    end
  end
end
