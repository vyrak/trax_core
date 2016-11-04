require 'spec_helper'

describe Method do
  before(:all) do
    class MyNewFakeClass < OpenStruct
      def self.i_dont_accept_arguments
        "one"
      end

      def self.i_accept_arguments(one, two)
        return [one, two]
      end

      def self.i_accept_splat_arguments(*args)
        return args
      end

      def self.i_accept_keyword_arguments(one:, two:)
        return [one, two]
      end
    end
  end

  subject { MyNewFakeClass.method(target_method) }

  context "method knows what it accepts" do
    describe '.i_dont_accept_arguments' do
      let(:target_method) { 'i_dont_accept_arguments' }

      it { expect(subject.accepts_arguments?).to eq false }
      it { expect(subject.accepts_keywords?).to eq false }
      it { expect(subject.accepts_arguments_splat?).to eq false }
    end
  end
end
