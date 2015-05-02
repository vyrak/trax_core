module Trax
  module Core
    module Mixin
      def on_mixed_in(&block)
        self.instance_variable_set(:@_on_mixed_in_block, block)
      end

      def extended(base)
        base.extend(::ActiveSupport::Concern)

        super(base)

        trace = ::TracePoint.new(:class) do |tracepoint|
          if tracepoint.self == base
            trace.disable

            if base.instance_variable_defined?(:@_before_extended_block)
              base.instance_variable_get(:@_before_extended_block).call
            end
          end
        end

        trace.enable

        trace = ::TracePoint.new(:end) do |tracepoint|
          if tracepoint.self == base #modules also trace end we only care about the class end
            trace.disable

            if base.instance_variable_defined?(:@_after_extended_block)
              base.instance_variable_get(:@_after_extended_block).call
              puts "AFTER EXTENDED"
            end
          end
        end

        trace.enable

        mod = super(base)

        mod

        mixin_namespace.register_mixin(base) unless self == ::Trax::Core::Mixin
      end

      module ClassMethods
        def on_mixed_in(&block)
          self.instance_variable_set(:@_on_mixed_in_block, block)
        end
      end

    end
  end
end
