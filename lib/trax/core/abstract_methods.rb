module Trax
  module Core
    module AbstractMethods
      extend ::ActiveSupport::Concern

      included do
        private
        class_attribute :_abstract_methods, :_abstract_class_methods, :_abstract_class_attributes
        self._abstract_methods = []
        self._abstract_class_methods = []
        self._abstract_class_attributes = []
      end

      module ClassMethods
        def abstract_method(*method_names)
          _abstract_methods.push(*method_names)
        end
        alias :abstract_methods :abstract_method

        def abstract_class_method(*method_names)
          _abstract_class_methods.push(*method_names)
        end
        alias :abstract_class_methods :abstract_class_method

        def abstract_class_attribute(*method_names)
          _abstract_class_attributes.push(*method_names)
          class_attribute(*method_names)
        end
        alias :abstract_class_attributes :abstract_class_attribute

        def inherited(subklass)
          klass = super(subklass)

          trace = ::TracePoint.new(:end) do |tracepoint|
            if tracepoint.self == subklass #modules also trace end we only care about the class end
              trace.disable

              if _abstract_methods.any?
                missing_instance_methods = ( Array(_abstract_methods) - subklass.instance_methods(false) )

                raise NotImplementedError, "#{subklass} must implement the following instance method(s) \n" \
                                           << "#{missing_instance_methods}" if missing_instance_methods.any?
              end

              if _abstract_class_methods.any?
                missing_class_methods = ( Array(_abstract_class_methods) - subklass.singleton_methods(false) )

                raise NotImplementedError, "#{subklass} must implement the following class method(s) \n" \
                                            << "#{missing_class_methods}" if missing_class_methods.any?
              end

              if _abstract_class_attributes.any?
                missing_class_attributes = _abstract_class_attributes.select{|_property| subklass.__send__(_property).blank? }

                raise NotImplementedError, "#{subklass} must set the following class attributes(s) \n" \
                                            << "#{missing_class_attributes}" if missing_class_attributes.any?
              end
            end
          end

          trace.enable

          klass
        end
      end
    end
  end
end
