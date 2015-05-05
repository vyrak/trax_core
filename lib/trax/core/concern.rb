module Trax
  module Core
    module Concern
      def included(base = nil, &block)
        unless base.respond_to?(:_mixins_config)
          base.class_attribute :_mixins_config
          base._mixins_config = {}
        end

        super(base, &block)

        trace = ::TracePoint.new(:end) do |tracepoint|
          if tracepoint.self == base
            trace.disable

            if self.instance_variable_defined?(:@_after_included_block)
              base.instance_eval(&self.instance_variable_get(:@_after_included_block))
            end

            if self.instance_variable_defined?(:@_on_mixed_in_block)
              base.instance_exec(base.mixins_config, &self.instance_variable_get(:@_on_mixed_in_block))
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

      module ClassMethods
        def configure_mixin(name, options = {})
          _mixins_config[name] = options
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

      def on_mixed_in(&block)
        self.instance_variable_set(:@_on_mixed_in_block, block)
      end
    end
  end
end
