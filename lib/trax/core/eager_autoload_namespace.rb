#note this has been loading some namespaces twice in some cases, so dont use me yet.
module Trax
  module Core
    module EagerAutoloadNamespace
      def self.extended(base)
        source_file_path = caller[0].partition(":")[0]

        base.module_eval do
          @eager_autoload_filepath = source_file_path
        end
      end

      def all
        @all ||= autoload_class_names.map do |klass|
          const_get(:"#{klass}")
        end
      end

      def autoload_file_paths
        @autoload_file_paths = ::Dir[module_path.join('*.rb')]
      end

      def autoload_class_names
        @autoload_class_names = autoload_file_paths.map do |path|
          ::File.basename(path.to_s).split(".rb").shift.try(:classify)
        end
      end

      def eager_autoload_filepath
        @eager_autoload_filepath
      end

      def module_path
        @module_path ||= ::Pathname.new(::File.path(eager_autoload_filepath).gsub(".rb", ""))
      end
    end
  end
end
