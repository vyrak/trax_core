require 'spec_helper'

describe ::Trax::Core::Concern do
  subject { ::SomeKlass }

  context "class including concern" do
    it { expect(subject.instance_variable_get(:@otherthing) ).to eq "otherthing" }
    it { expect(subject::SOMETHING).to eq "ANYTHING" }
  end

  context "module extending concern" do
    subject { ::SomeConcernConcern }
    it { expect(subject.some_mod_attribute ).to eq [ :Blahgity ] }
  end
end
