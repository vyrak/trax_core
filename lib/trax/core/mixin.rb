module Trax
  module Core
    module Mixin
      # extend ::ActiveSupport::Concern
      # extend ::Trax::Core::Concern

      def self.extended(base)
        base.extend(::ActiveSupport::Concern)

        super(base)

        mixin_namespace.register_mixin(base) unless self == ::Trax::Core::Mixin
      end

      # before_extended do
      #   puts "BEFORE EXTENDED"
      # end
      #
      # after_extended do
      #   puts "AFTER EXTENDED"
      # end
      #
      # included do
      #   puts "INCLUDED"
      # end
      #
      # def self.extended(base)
      #   base.extend(::ActiveSupport::Concern)
      #
      #   mod = super(base)
      #
      #   trace = ::TracePoint.new(:end) do |tracepoint|
      #     if tracepoint.self == mod #modules also trace end we only care about the class end
      #       trace.disable
      #     end
      #   end
      #
      #   trace.enable
      #
      #   mod
      # end
      #
      # def after_included(&block)
      #   self.instance_variable_set(:@_after_included_block, block)
      # end
      #
      # def mixed_in(&block)
      #   after_included(&block)
      # end
      #
      # def mixed(&block)
      #   after_included(&block)
      # end
    end
  end
end
