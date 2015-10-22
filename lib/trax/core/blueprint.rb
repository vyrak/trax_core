module Trax
  module Core
    class Blueprint < ::Trax::Core::Types::Struct
      def self.const_missing(const_name)
        if fields.const_defined?(const_name, false)
          result = const_set(const_name, fields.const_get(const_name)) if fields.const_defined?(const_name, false)
        else
          result = super(const_name)
        end

        result
      end
    end
  end
end
