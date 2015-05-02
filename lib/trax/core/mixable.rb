module Trax
  module Core
    module Mixable
      extend ::ActiveSupport::Concern

      included do
        class_attribute :registered_mixins

        self.registered_mixins = {}
      end

      # def self.mixin(key, options = {})
      #   raise ::Trax::Core::Errors::MixinNotRegistered.new(
      #     model: self.name,
      #     mixin: key
      #   )  unless mixin_namespace.mixin_registry.key?(key)
      #
      #   mixin_module = mixin_namespace.mixin_registry[key]
      #   self.registered_mixins[key] = mixin_module
      #
      #   self.class_eval do
      #     include(mixin_module) unless self.ancestors.include?(mixin_module)
      #
      #     options = {} if options.is_a?(TrueClass)
      #     options = { options => true } if options.is_a?(Symbol)
      #     mixin_module.apply_mixin(self, options) if mixin_module.respond_to?(:apply_mixin)
      #
      #     if mixin_module.instance_variable_defined?(:@_after_included_block)
      #       block = mixin_module.instance_variable_get(:@_after_included_block)
      #
      #       instance_exec(options, &block)
      #     end
      #   end
      # end
      #
      # def mixins(*args)
      #   options = args.extract_options!
      #
      #   if(!options.blank?)
      #     options.each_pair do |key, val|
      #       self.mixin(key, val)
      #     end
      #   else
      #     args.map{ |key| mixin(key) }
      #   end
      # end
      #
      # def self.mixins(*args)
      #   options = args.extract_options!
      #
      #   if(!options.blank?)
      #     options.each_pair do |key, val|
      #       self.mixin(key, val)
      #     end
      #   else
      #     args.map{ |key| mixin(key) }
      #   end
      # end

      # after_extended do
      #   binding.pry
      # end

      module ClassMethods
        def mixin(key, options = {})
          raise ::Trax::Core::Errors::MixinNotRegistered.new(
            source: self.name,
            mixin: key,
            mixin_namespace: mixin_namespace
          )  unless mixin_namespace.mixin_registry.key?(key)

          mixin_module = mixin_namespace.mixin_registry[key]
          self.registered_mixins[key] = mixin_module

          self.class_eval do
            include(mixin_module) unless self.ancestors.include?(mixin_module)

            options = {} if options.is_a?(TrueClass)
            options = { options => true } if options.is_a?(Symbol)
            mixin_module.apply_mixin(self, options) if mixin_module.respond_to?(:apply_mixin)

            if mixin_module.instance_variable_defined?(:@_after_included_block)
              block = mixin_module.instance_variable_get(:@_after_included_block)

              instance_exec(options, &block)
            end
          end
        end

        def mixins(*args)
          options = args.extract_options!

          if(!options.blank?)
            options.each_pair do |key, val|
              self.mixin(key, val)
            end
          else
            args.map{ |key| mixin(key) }
          end
        end
      end
    end
  end
end
