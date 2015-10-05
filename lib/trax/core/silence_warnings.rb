module Trax
  module Core
    module SilenceWarnings
      extend ::ActiveSupport::Concern

      module ClassMethods
        def silence_warnings
          original_verbosity = $VERBOSE
          $VERBOSE = nil
          result = yield
          $VERBOSE = original_verbosity
          return result
        end
      end
    end
  end
end
