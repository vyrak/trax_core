module Trax
  module Core
    module NamedModule
      # examples: (by default, any module args passed after the name of the module will be applied via extend)
      # With Args:
      # Trax::Core::NamedModule.new("Ecommerce::ItemExtensions", ::Ecommerce::PricingExtension, Ecommerce::ShippingExtension)
      # With :extensions keyword
      # Trax::Core::NamedModule.new("Ecommerce::ItemExtensions", :extensions => [::Ecommerce::PricingExtension])
      # With :includes keyword
      # Trax::Core::NamedModule.new("Ecommerce::ItemExtensions", :includes => [::Ecommerce::ShippingExtension])

      def self.new(_name, *_extensions, **options, &block)
        module_object = ::Object.set_fully_qualified_constant(_name, ::Module.new do
          define_singleton_method(:name) do
            _name
          end
        end)

        module_object.module_eval(&block) if block_given?

        includes = [options.extract!(:includes).fetch(:includes) { nil }].compact.flatten
        extensions = [options.extract!(:extensions).fetch(:extensions) { nil }, _extensions].compact.flatten

        extensions.each_with_object(module_object) { |ext, mod| mod.extend(ext) } if extensions.length
        includes.each_with_object(module_object){ |ext, mod| mod.include(ext) } if includes.length

        module_object
      end
    end
  end
end
