module Trax
  module Core
    module Types
      module Behaviors
        module ArrayOfMembers
          extend ::ActiveSupport::Concern

          included do
            include ::Enumerable

            class_attribute :member_class
          end

          def initialize(*args)
            super([args].flatten.compact)
            self.map!{ |ele| self.class.member_class.new(ele) } if self.any?
          end

          def <<(val)
            if self.class.member_class && val.class == self.class.member_class
              super(val)
            else
              super(self.class.member_class.new(val))
            end
          end

          def each(&block)
            yield __getobj__.each(&block)
          end
        end
      end
    end
  end
end
