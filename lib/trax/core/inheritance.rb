module Trax
  module Core
    module Inheritance
      extend ::ActiveSupport::Concern

      module ClassMethods
        def inherited(subklass)
          if self.instance_variable_defined?(:@_on_inherited_block)
            subklass.instance_eval(&self.instance_variable_get(:@_after_inherited_block))
          end

          trace = ::TracePoint.new(:end) do |tracepoint|
            if tracepoint.self == subklass
              trace.disable

              if self.instance_variable_defined?(:@_after_inherited_block)
                subklass.instance_eval(&self.instance_variable_get(:@_after_inherited_block))
              end
            end
          end

          trace.enable
        end

        def after_inherited(&block)
          self.instance_variable_set(:@_after_inherited_block, block)
        end

        def on_inherited(&block)
          self.instance_variable_set(:@_on_inherited_block, block)
        end
      end
    end
  end
end
