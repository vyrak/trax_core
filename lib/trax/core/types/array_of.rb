module Trax
  module Core
    module Types
      class ArrayOf < ::Trax::Core::Types::Array
        include ::Trax::Core::Types::Behaviors::ArrayOfMembers

        def self.[](member_class)
          return of(member_class)
        end

        def self.type
          :array_of
        end
      end
    end
  end
end
