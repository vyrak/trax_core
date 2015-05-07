module Trax
  module Core
    module Mixin
      def on_mixed_in(&block)
        self.instance_variable_set(:@_on_mixed_in_block, block)
      end

      def before_mixed_in(&block)
        self.instance_variable_set(:@_before_mixed_in_block, block)
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
