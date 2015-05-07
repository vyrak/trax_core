module Trax
  module Core
    module Inheritance
      extend ::ActiveSupport::Concern

      module ClassMethods
        def inherited(subklass)
          klass = super(subklass)
          klass.class_attribute(:_after_inherited_block)

          trace = ::TracePoint.new(:end) do |tracepoint|
            if tracepoint.self == subklass
              trace.disable
            end
          end

          trace.enable
        end
      end
    end
  end
end
