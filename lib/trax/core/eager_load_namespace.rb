module Trax
  module Core
    module EagerLoadNamespace
      def self.extended(base)
        source_file_path = caller[0].partition(":")[0]

        base.module_attribute(:eager_autoload_filepath) { source_file_path }
        base.module_attribute(:module_path) { ::Pathname.new(::File.path(base.eager_autoload_filepath).gsub(".rb", "")) }

        ::Trax::Core::FS::Directory.new(base.module_path).files.each do |file|
          load file
        end

        super(base)
      end
    end
  end
end
