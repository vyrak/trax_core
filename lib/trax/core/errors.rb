require 'hashie/dash'
require 'hashie/mash'

module Trax
  module Core
    module Errors
      # A simple inheritable error class
      # Because Im sick of defining in every project a base error class
      # and IMO arguments should have explicit names when thrown to give context to the error
      # (while not being order dependent)
      # and perhaps its a bad idea to require arguments when throwing errors, but
      # you can still make them as generic as you want
      # & the idea is fail fast and provide more targeted & descriptive error tracking data

      # Example:
      #
      #  class AbstractInstanceMethodNotDefined < ::Trax::Core::Errors::Base
      #    argument :method_name, :required => true
      #    argument :klass, :required => true
      #
      #    message {
      #      "Abstract instance method, #{method_name} not defined for #{klass}"
      #    }
      #  end
      #
      #  raise ::AbstractInstanceMethodNotDefined.new(:method_name => "my_method", :klass => self.class.name)

      class Arguments < ::Hashie::Dash
      end

      class Base < StandardError
        class_attribute :_message

        #on inherit of Trax::Core::Errors::Base, inherit from arguments class above to provide simple
        #dsl options / typecasting and stuff to our errors.
        def self.inherited(subklass)
          subklass.class_eval do
            arguments_class_name = "#{subklass.name.demodulize}Arguments"
            arguments_klass = const_set(arguments_class_name, ::Class.new(::Trax::Core::Errors::Arguments)) unless const_defined?(arguments_class_name)
            @_permitted_arguments_klass = arguments_klass
            @_permitted_arguments = arguments_klass.new

            attr_reader :_permitted_arguments
            attr_reader :_permitted_arguments_klass
          end
        end

        def self.argument(method_name, *args)
          permitted_arguments_klass.property(method_name, *args)

          define_method(method_name) do
            arguments_instance.__send__(method_name)
          end
        end

        def self.permitted_arguments_klass
          @_permitted_arguments_klass
        end

        def self.permitted_arguments
          @_permitted_arguments
        end

        def self.message(&block)
          self._message = block
        end

        # if no properties have been defined using argument method, wrap in Mash
        def self.error_arguments_klass
          @error_arguments_klass ||= (permitted_arguments_klass.properties.length) ? permitted_arguments_klass : ::Hashie::Mash
        end

        attr_reader :arguments_instance

        def initialize(**_attributes)
          @arguments_instance = self.class.permitted_arguments_klass.new(_attributes)

          super(message)
        end

        def message
          self.instance_eval(&self.class._message)
        end
      end

      class ConfigurationError < ::Trax::Core::Errors::Base
        argument :source, :required => true
        argument :messages

        message {
          "Error configuring #{source}, \n" \
          "#{messages.join('\n')}"
        }
      end

      class MixinNotRegistered < ::Trax::Core::Errors::Base
        argument :mixin
        argument :source
        argument :mixin_namespace

        message {
          "#{source} tried to load mixin: #{mixin}, whichdoes not exist in " \
          "registry. Registered mixins were #{mixin_namespace.mixin_registry.keys.join(', ')} \n"
        }
      end

      class DuplicateEnumValue < ::Trax::Core::Errors::Base
        argument :value
        argument :klass
        message {
          "#{klass} duplicate value #{value}"
        }
      end
    end
  end
end
