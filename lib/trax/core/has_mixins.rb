module Trax
  module Core
    module HasMixins
      module ClassMethods
        def register_mixin(mixin_klass, key = nil)
          mixin_key = mixin_klass.respond_to?(:mixin_registry_key) ? mixin_klass.mixin_registry_key : (key || mixin_klass.name.demodulize.underscore.to_sym)

          return if mixin_registry.key?(mixin_key)
          mixin_registry[mixin_key] = mixin_klass
        end
      end

      def self.extended(base)
        base.module_attribute(:mixin_registry) { Hash.new }
        base.extend(ClassMethods)

        base.define_configuration_options! do
          option :auto_include, :default => false
          option :auto_include_mixins, :default => []
        end

        mixin_module = base.const_set("Mixin", ::Module.new)
        mixin_module.module_attribute(:mixin_namespace) { base }

        mixin_module.module_eval do
          def self.extended(base)
            base.extend(ActiveSupport::Concern)
            super(base)
            puts base
            mixin_namespace.register_mixin(base)
          end
        end

        # mixin_namespace.register_mixin(base) unless self == ::Trax::Core::Mixin
        # mixin_module.extend(::Trax::Core::Mixin)


        mixable_module = base.const_set("Mixable", ::Module.new)

        mixable_module.module_attribute(:mixin_namespace) { base }
        mixable_module.extend(::ActiveSupport::Concern)

        mixable_module.included do
          class_attribute :mixin_namespace
          self.mixin_namespace = base
        end

        mixable_module.include(::Trax::Core::Mixable)
        # mixable_module.module_eval do
        #   # extend ::ActiveSupport::Concern
        # end
        # mixable_module.extend(::Trax::Core::Mixable)
        # mixable
        #
        # binding.pry

        # base.class_eval do
        #
        # end

        # base.extend(::Trax::Core::Concern)
        # base.extend(ClassMethods)

        # base.class_eval do
        #   included do
        #     class_attribute :registered_mixins
        #
        #     self.registered_mixins = {}
        #   end
        # end

        super(base)
      end
    end
  end
end
