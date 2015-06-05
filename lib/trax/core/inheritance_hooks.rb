module Trax
  module Core
    module InheritanceHooks
      extend ::ActiveSupport::Concern

      module ClassMethods
        def inherited(subklass)
          super(subklass)

          if self.instance_variable_defined?(:@_on_inherited_block)
            subklass.instance_eval(&self.instance_variable_get(:@_on_inherited_block))
          end

          if subklass.class == Class
            #this supports anonymous classes created with a block passed, i.e.
            # Class.new(Enum, &Proc.new{VAL=1})
            # otherwise Class.new wont be caught by tracepoint statement below
            trace = ::TracePoint.new(:b_return) do |tracepoint|
              if tracepoint.self.class == Class
                if self.instance_variable_defined?(:@_after_inherited_block)
                  subklass.instance_eval(&self.instance_variable_get(:@_after_inherited_block))
                end

                trace.disable
              end
            end

            trace.enable
          else
            trace = ::TracePoint.new(:end) do |tracepoint|
              if tracepoint.self == subklass
                if self.instance_variable_defined?(:@_after_inherited_block)
                  subklass.instance_eval(&self.instance_variable_get(:@_after_inherited_block))
                end

                trace.disable
              end
            end

            trace.enable

            self
          end
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
