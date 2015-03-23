require 'hashie/dash'
require 'active_model'
require 'active_model/validations'

module Trax
  module Core
    class Configuration
      include ActiveModel::Validations

      class_attribute :source

      def initialize
        set_default_values

        yield self if block_given?

        raise_errors unless self.valid?
      end

      def set_default_values
        self.class.configurable_options.select{|attr_name, hash| hash.key?(:default) }.each_pair do |attr_name,hash|
          __send__("#{attr_name}=", hash[:default])
        end
      end

      def self.inherited(subklass)
        super(subklass)

        subklass.class_attribute :configurable_options
        subklass.configurable_options = {}
      end

      def self.option(attr_name, options = {})
        attr_accessor attr_name

        validates_presence_of(attr_name) if(options.key?(:required))

        if(options.key?(:validates))
          validates(attr_name, options[:validates])
        end

        define_method("#{attr_name}=") do |val|
          value = options.key?(:setter) ? options[:setter].call(val) : val
          instance_variable_set("@#{attr_name}", value)

          raise_errors unless self.valid?
        end

        if(options.key?(:getter))
          define_method(attr_name) do |val|
            options[:getter].call(val)
          end
        end

        self.configurable_options[attr_name] = options
      end

      def merge!(options = {})
        options.each_pair{ |k,v| __send__("#{k}=", v) }
      end

      def raise_errors
        raise Trax::Core::Errors::ConfigurationError.new(
          :messages => self.errors.full_messages,
          :source => self.class.name
        )
      end
    end
  end
end
