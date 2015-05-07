module Trax
  module Core
    module IsolatedMixin
      def included(base = nil, &block)
        unless base.respond_to?(:_concerns)
          base.class_attribute :_concerns_config
          base._concerns_confg = {}
        end

        base.extend(ClassMethods)

        super(base, &block)

        trace = ::TracePoint.new(:end) do |tracepoint|
          if tracepoint.self == base
            trace.disable

            if self.instance_variable_defined?(:@_after_included_block)
              base.instance_eval(&self.instance_variable_get(:@_after_included_block))
            end

            if self.instance_variable_defined?(:@_on_concern_included_block)
              base.instance_exec(base._concerns_config[self.name.demodulize.underscore.to_sym], &self.instance_variable_get(:@_on_concern_included_block))
            end
          end
        end

        trace.enable
      end

      def self.extended(base)
        base.extend(::ActiveSupport::Concern)
        base.extend(::Trax::Core::IsolatedMixin::ClassMethods)

        super(base)

        trace = ::TracePoint.new(:end) do |tracepoint|
          if tracepoint.self == base
            trace.disable

            if base.instance_variable_defined?(:@_after_extended_block)
              base.instance_variable_get(:@_after_extended_block).call
            end
          end
        end

        trace.enable
      end

      module ClassMethods
        def configure_concern(name, options = {})
          _concerns_config[name] = options
        end
      end

      def after_extended(&block)
        self.instance_variable_set(:@_after_extended_block, block)
      end

      def after_included(&block)
        self.instance_variable_set(:@_after_included_block, block)
      end

      def mixed_in(&block)
        after_included(&block)
      end

      def mixed(&block)
        after_included(&block)
      end

      def on_concern_included(&block)
        self.instance_variable_set(:@_on_concern_included_block, block)
      end
    end
  end
end
