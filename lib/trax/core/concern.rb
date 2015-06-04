module Trax
  module Core
    module Concern
      def self.extended(base)
        base.extend(::ActiveSupport::Concern)

        trace = ::TracePoint.new(:end) do |tracepoint|
          if tracepoint.self.singleton_class.included_modules.first == base
            trace.disable

            if base.instance_variable_defined?(:@_after_extended_block)
              tracepoint.self.module_exec(base, &base.instance_variable_get(:@_after_extended_block))
            end
          end
        end

        trace.enable

        base
      end

      def included(base = nil, &block)
        super(base, &block) if defined?(super)

        trace = ::TracePoint.new(:end) do |tracepoint|
          if tracepoint.self == base
            trace.disable

            if self.instance_variable_defined?(:@_after_included_block)
              base.instance_eval(&self.instance_variable_get(:@_after_included_block))
            end
          end
        end

        trace.enable

        base
      end

      def after_included(&block)
        self.instance_variable_set(:@_after_included_block, block)
      end

      def after_extended(&block)
        self.instance_variable_set(:@_after_extended_block, block)
      end
    end
  end
end
