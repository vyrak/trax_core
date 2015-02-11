module Trax
  module Core
    module AbstractMethods
      extend ::ActiveSupport::Concern

      included do
        class_attribute :_abstract_instance_methods
        class_attribute :_abstract_class_methods

        self._abstract_instance_methods = ::Set.new
        self._abstract_class_methods = ::Set.new

        # def self.after_inherited(subclass)
        #   binding.pry
        # end
#         def self.inherited(subclass)
#
#
# #           after_inherited(subclass) do
# # binding.pry
# #           end
#
#           # binding.pry
#
#           super(subclass)
#
#
#
#
#
#           # subclass.after_inherited do |sub|
#           #   binding.pry
#           # end
#
#
#
#
#
#           # after_inherited(subclass)
#
#
#
#           # subclass.after_inherited(subclass) do
#           #   _abstract_instance_methods.each do |method_name|
#           #     raise ::Trax::Core::Errors::AbstractInstanceMethodNotDefined.new(
#           #       :klass => subclass.name,
#           #       :method_name => method_name
#           #     ) unless subclass.instance_methods.include?(method_name)
#           #   end
#           # end
#
#           # subclass.inherited(child) do |child|
#           #   binding.pry
#           # end
#
#           # self.after_inherited(subclass) do |child|
#           #   binding.pry
#           #
#           # end
#         end

        # def self.after_inherited(sub)
        #
        #   binding.pry
        # end

        # after_inherited do |child|
        #   binding.pry
        #
        #
        # end
      end

      module ClassMethods
        # def inherited(subclass)
        #   super(subclass)
        #
        #   after_inherited do
        #     binding.pry
        #     _abstract_instance_methods.each do |method_name|
        #       puts subclass.instance_methods.include?(method_name)
        #
        #       # raise ::Trax::Core::Errors::AbstractInstanceMethodNotDefined.new(
        #       #   :klass => subclass.name,
        #       #   :method_name => method_name
        #       # ) unless subclass.instance_methods.include?(method_name)
        #     end
        #   end
        # end
        # def after_inherited(subclass)
        #
        # end

        # def inherited(subclass)
        #   super(subclass)
        #
        #   # binding.pry
        #
        #   after_inherited(subclass) do |child|
        #     binding.pry
        #     _abstract_instance_methods.each do |method_name|
        #       raise ::Trax::Core::Errors::AbstractInstanceMethodNotDefined.new(
        #         :klass => subclass.name,
        #         :method_name => method_name
        #       ) unless subclass.instance_methods.include?(method_name)
        #     end
        #   end
        #
        #   # super(subclass)
        # end

        def abstract_method(*args)
          args.each do |arg|
            _abstract_instance_methods << arg
          end
        end

        def abstract_class_method(*args)
          args.each do |arg|
            _abstract_class_methods << arg
          end
        end
      end
    end
  end
end
