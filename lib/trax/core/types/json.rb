module Trax
  module Core
    module Types
      class Json
        def self.type
          :json
        end

        def self.to_schema
          ::Trax::Core::Definition.new(
            :name => self.name.demodulize.underscore,
            :source => self.name,
            :type => self.type
          )
        end
      end
    end
  end
end
