module Trax
  module Core
    module Concern
      def included(base = nil, &block)
        super(base, &block)

        trace = ::TracePoint.new(:end) do |tracepoint|
          if tracepoint.self == base
            trace.disable

            if self.instance_variable_defined?(:@_after_included_block)
              base.instance_eval(&self.instance_variable_get(:@_after_included_block))
            end
          end
        end

        trace.enable
      end

      def self.extended(base)
        base.extend(::ActiveSupport::Concern)

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

      def after_extended(&block)
        self.instance_variable_set(:@_after_extended_block, block)
      end

      def after_included(&block)
        self.instance_variable_set(:@_after_included_block, block)
      end
    end
  end
end
