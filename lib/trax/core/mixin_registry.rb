module Trax
  module Core
    class MixinRegistry
      def self.extended(base)
        base.extend(::ActiveSupport::PerThreadRegistry)
        super(base)
      end
    end
  end
end
