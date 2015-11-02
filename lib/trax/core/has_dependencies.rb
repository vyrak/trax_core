module Trax
  module Core
    module HasDependencies
      def self.included(klass)
        klass.class_attribute :_depends_on
        klass.class_attribute :_depends_on_config
        klass._depends_on_config = {}
        klass._depends_on = []
        klass.extend(ClassMethods)
        klass.prepend(InstanceMethods)
      end

      module ClassMethods
        def depends_on(*args, pass_options_to_super:true)
          self._depends_on += args
          self._depends_on.map{|_dependency_key| self.__send__("attr_reader", _dependency_key) }
          self._depends_on_config[:pass_options_to_super] = pass_options_to_super
        end
      end

      module InstanceMethods
        def initialize(*args, **options)
          if self.class._depends_on.length
            missing_dependencies = self.class._depends_on.select{|k| !options.key?(k) }

            if missing_dependencies.any?
              raise ::Trax::Core::Errors::MissingRequiredDependency.new(:source => self.class, :missing_dependencies => missing_dependencies)
            else
              options.extract!(*self._depends_on).each_pair do |k,v|
                instance_variable_set("@#{k}", v)
              end
            end
          end

          if self.class._depends_on_config[:pass_options_to_super]
            super(*args, **options)
          else
            super(*args)
          end
        end
      end
    end
  end
end
