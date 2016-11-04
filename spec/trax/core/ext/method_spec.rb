require 'spec_helper'

describe Method do
  before(:all) do
    class MyNewFakeClass < OpenStruct
      def self.i_dont_accept_arguments
        "one"
      end

      def self.i_accept_ordinal_arguments(one, two)
        return [one, two]
      end

      def self.i_accept_optional_ordinal_arguments(one=nil, two=nil)
        return [one, two]
      end

      def self.i_accept_splat_arguments(*args)
        return args
      end

      def self.i_accept_keyword_arguments(three:nil, one:, two:)
        return [one, two]
      end

      def self.i_accept_keyword_arguments_splat(**options)
        return options
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

    describe '.i_accept_ordinal_arguments' do
      let(:target_method) { 'i_accept_ordinal_arguments' }

      it { expect(subject.accepts_arguments?).to eq true }
      it { expect(subject.accepts_keywords?).to eq false }
      it { expect(subject.accepts_arguments_splat?).to eq false }
    end

    describe '.i_accept_optional_ordinal_arguments' do
      let(:target_method) { 'i_accept_optional_ordinal_arguments' }

      it { expect(subject.accepts_arguments?).to eq true }
      it { expect(subject.accepts_optional_arguments?).to eq true }
      it { expect(subject.accepts_keywords?).to eq false }
      it { expect(subject.accepts_arguments_splat?).to eq false }
    end

    describe '.i_accept_splat_arguments' do
      let(:target_method) { 'i_accept_splat_arguments' }

      it { expect(subject.accepts_arguments?).to eq true }
      it { expect(subject.accepts_keywords?).to eq false }
      it { expect(subject.accepts_arguments_splat?).to eq true }
    end

    describe '.i_accept_keyword_arguments' do
      let(:target_method) { 'i_accept_keyword_arguments' }

      it { expect(subject.accepts_arguments?).to eq false }
      it { expect(subject.accepts_keywords?).to eq true }
      it { expect(subject.accepts_arguments_splat?).to eq false }
    end

    describe '.i_accept_keyword_arguments_splat' do
      let(:target_method) { 'i_accept_keyword_arguments_splat' }

      it { expect(subject.accepts_arguments?).to eq false }
      it { expect(subject.accepts_arguments_splat?).to eq false }
      it { expect(subject.accepts_keywords?).to eq true }
      it { expect(subject.accepts_keywords_splat?).to eq true }
    end
  end
end
