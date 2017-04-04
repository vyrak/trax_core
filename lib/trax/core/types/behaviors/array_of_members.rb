module Trax
  module Core
    module Types
      module Behaviors
        module ArrayOfMembers
          extend ::ActiveSupport::Concern

          included do
            # include ::Enumerable
            #
            class_attribute :member_class unless self.respond_to?(:member_class) && self.member_class
          end

          def initialize(*args)
            super([args].flatten.compact)
            @value = @value.map{ |ele| self.class.member_class.new(ele) }
            # @value.map!{ |ele| self.class.member_class.new(ele) }
            # @value = @args.map!{ |ele| self.class.member_class.new(ele) }
            # self.map!{ |ele| self.class.member_class.new(ele) }
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
