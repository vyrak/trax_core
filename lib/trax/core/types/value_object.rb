module Trax
  module Core
    module Types
      class ValueObject < SimpleDelegator
        def initialize(val)
          @value = val
        end

        def __getobj__
          @value
        end

        def self.symbolic_name
          name.demodulize.underscore.to_sym
        end

        def self.to_sym
          :value
        end
      end
    end
  end
end
