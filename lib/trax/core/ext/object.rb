require "active_support/core_ext/object/try"

class Object
  # Defines a Configuration Class within a target module namespace, or nested class
  # i.e. configuration_for(::Ecommerce::Cart) will define
  # Ecommerce::Cart::Configuration class, inherited form Trax::Core::Configuration
  # And we can then define specific configuration options, for that class, on that class
  def configuration_for(target, as = :configuration, &blk)

    target.const_set("Configurations", Class.new) unless const_defined?("Configurations")
    target.const_get("Configurations").__send__(:attr_accessor, as)

    target.class_eval do
      const_get("Configurations").const_set(as.to_s.classify, ::Class.new(::Trax::Core::Configuration))
      const_get("Configurations").const_get(as.to_s.classify).instance_eval(&blk)

      unless self.respond_to?(:configure)
        define_singleton_method(:configure)
        def self.configure(target_configuration = :configuration, &block)
          configuration_klass = self::Configurations.const_get(target_configuration)
          configuration_klass

          instance_variable_set(:"@#{target_configuration}", const_get(target_configuration.classify).new(&block))
          @_configuration = const_get(target_configuration.classify).new(&block)
        end
      end

      def self.config
        _configuration
      end
    end
  end

  def define_configuration_options(as=:configuration, &block)
    configuration_for(self, as, &block)
  end

  alias_method :define_configuration, :define_configuration_options
  alias_method :has_configuration, :define_configuration_options

  #following method stolen from abrandoned https://rubygems.org/gems/try_chain
  def try_chain(*symbols)
    return nil if self.nil?

    symbols = symbols.flatten
    symbols.compact!

    symbols.reduce(self) do |result, symbol|
      result = result.try(symbol)
      break nil if result.nil?
      result
    end
  end
end
