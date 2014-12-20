require 'spec_helper'

describe ::Module do
  subject { Trax::Core }

  describe ".recursively_define_namespaced_class" do
    context "when class namespace does not exist at global module level" do
      before do
        Trax.recursively_define_namespaced_class("Somefake::Thing")
      end

      it { Trax::Somefake::Thing.class == Object }
    end

    context "when class namespace does exist at global module level" do
      before do
        Trax.recursively_define_namespaced_class("Core::FakeKlass", Hash)
      end

      it { Trax::Core::FakeKlass.superclass.should == Hash }
    end
  end
end
