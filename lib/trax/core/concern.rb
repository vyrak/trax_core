module Trax
  module Core
    module Concern
      def included(base = nil, &block)
        puts "INCLUDEDFROM CONCERN"
        super(base, &block)
      end

      def self.extended(base)
        base.extend(::ActiveSupport::Concern)



        trace = ::TracePoint.new(:class) do |tracepoint|
          if tracepoint.self == base
            trace.disable

            if base.instance_variable_defined?(:@_before_extended_block)
              base.instance_variable_get(:@_before_extended_block).call
            end
          end
        end

        trace.enable

        # binding.pry

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

        # ::Trax::Model.register_mixin(base)
      end

      def before_extended(&block)
        self.instance_variable_set(:@_before_extended_block, block)
      end

      def self.before_extended(&block)
        self.instance_variable_set(:@_before_extended_block, block)
      end

      def after_extended(&block)
        self.instance_variable_set(:@_after_extended_block, block)
      end

      def after_included(&block)
        self.instance_variable_set(:@_after_included_block, block)
      end

      def before_included(&block)
        self.instance_variable_set(:@_before_included_block, block)
      end

      def mixed_in(&block)
        after_included(&block)
      end

      def mixed(&block)
        after_included(&block)
      end
    end
  end
end
