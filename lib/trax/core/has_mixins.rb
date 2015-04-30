module Trax
  module Core
    module HasMixins
      module ClassMethods
        def mixin(key, options = {})
          raise ::Trax::Core::Errors::MixinNotRegistered.new(
            model: self.name,
            mixin: key
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

      def self.extended(base)
        mixin_registry_module = const_set("#{base.name}::Mixins", ::Module.new)
        mixin_registry_module.extend(::ActiveSupport::PerThreadRegistry)

        mixin_module = const_set("#{base.name}::Mixin", ::Trax::Core::Mixin)

        base.extend(::Trax::Core::Concern)
        base.extend(ClassMethods)

        base.class_attribute :mixin_registry
        base.mixin_namespace = base.name
      end
    end
  end
end
