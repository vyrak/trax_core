require "active_support/core_ext/object/try"

class Object
  # Defines a Configuration Class within a target module namespace, or nested class
  # i.e. configuration_for(::Ecommerce::Cart) will define
  # Ecommerce::Cart::Configuration class, inherited form Trax::Core::Configuration
  # And we can then define specific configuration options, for that class, on that class
  def configuration_for(target, &blk)
    target.class_eval do
      class << self
        attr_accessor :_configuration
      end

      const_set("Configuration", ::Class.new(::Trax::Core::Configuration))
      const_get("Configuration").instance_eval(&blk)

      def self.configure(&block)
        @_configuration = const_get("Configuration").new(&block)
      end

      def self.config
        _configuration
      end
    end
  end

  def define_configuration_options(&block)
    configuration_for(self, &block)
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
