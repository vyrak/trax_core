# clearly this should be its own gem
# or at least parts of it
# But this is an advanced set of file tools built around ruby stdlib file/dir clases
# that lets you do stuff like collect all the files in the current directory
# and its a WIP I ripped out of my project hastily so u done been warned

# Examples:
#
# Get all files in the current dir
# ::Trax::Core::FS::CurrentDirectory.new.files
#
# Get all ruby files in current dir
# ::Trax::Core::FS::CurrentDirectory.new.files.by_extension(".rb")
#
# Get all ruby files in target directory
# ::Trax::Core::FS::Directory.new('/users/jayre/whatever').files.by_extension(".rb")
#
# RECURSIVELY get files + children files + childrens children (yarr)
# ::Trax::Core::FS::Directory.new('/users/jayre/whatever').files(true)
#

module Trax
  module Core
    module FS
      module Scopes
        def by_extension(*extensions)
          matches = select{ |file|
            extensions.include?(file.extension)
          }
        end
      end

      class Files < SimpleDelegator
        include ::Enumerable
        include ::Trax::Core::FS::Scopes

        attr_accessor :files

        def initialize(*args)
          @files = (args || []).flatten.compact.uniq
        end

        def __getobj__
          @files
        end

        def each(&block)
          @files.each do |file|
            block.call(file)
          end
        end
      end

      class Directory < Dir
        attr_accessor :files
        attr_accessor :directories
        attr_accessor :path
        attr_accessor :all

        def self.[](path)
          file_path = path.is_a?(Pathname) ? path : Pathname.new(path)
          new(file_path)
        end

        def [](arg)
          self.class.new(@path.join(arg).to_s)
        end

        def initialize(filepath)
          @path = ::Pathname.new(filepath)
        end

        def all
          @all ||= ::Dir[path.join("*")].map do |folder_or_file|
            listing = ::Pathname.new(folder_or_file)
            listing.directory? ? self.class.new(listing) : ::Trax::Core::FS::Listing.new(listing)
          end
        end

        def directories(*args)
          folders(*args)
        end

        def each
          yield(entries)
        end

        def entries
          @entries ||= ::Dir.entries(path).map do |file_path|
            path = ::Pathname.new(file_path) unless file_path.is_a?(Pathname)
            path.directory? ? ::Trax::Core::FS::Directory.new(path) : ::Listing.new(path)
          end
        end

        def files(recurse = false)
          @files ||= begin
            if recurse
              current_directory_files = Files.new(all.select{|path| path.is_a?(::Trax::Core::FS::Listing) })

              directories.map do |dir|
                next unless dir.files(true) && dir.files(true).any?
                current_directory_files.files += dir.files(true)
              end if directories.any?

              current_directory_files || ::Trax::Core::FS::Files.new
            else
              Files.new(all.select{|path| path.is_a?(::Trax::Core::FS::Listing) })
            end
          end
        end

        def folders(recurse = false)
          @folders ||= begin
            if recurse
              current_directory_directories = all.select{|path| path.is_a?(::Trax::Core::FS::Directory) }

              current_directory_directories += folders(true).map do |dir|
                dir.directories(true).any? ? dir.directories(true) : []
              end if directories(true) && directories(true).any?

              current_directory_directories
            else
              all.select{ |path| path.is_a?(::Trax::Core::FS::Directory) }
            end
          end
        end

        def reload
          remove_instance_variable(:@folders) if defined?(:@folders)
          remove_instance_variable(:@files) if defined?(:@files)
          self
        end

        def inspect
          ivars = self.instance_variables.map{|v| "#{v}=#{instance_variable_get(v).to_s}"}
          "#<#{self.class}: #{ivars}>"
        end

        def images
          files.select{|file| file.image? }
        end
      end

      class CurrentFileDirectory < SimpleDelegator
        include ::Enumerable

        attr_accessor :directory, :path

        def initialize
          @path = ::Pathname.new(::File.path(__FILE__))
          @directory = ::Trax::Core::FS::Directory.new(@path)
        end

        def __getobj__
          @directory
        end

        def each
          yield @directory
        end
      end

      class CurrentDirectory < CurrentFileDirectory

      end

      class CurrentWorkingDirectory < SimpleDelegator
        include ::Enumerable

        attr_accessor :directory, :path

        def initialize
          @path = ::Pathname.new(::Dir.pwd)
          @directory = ::Trax::Core::FS::Directory.new(@path)
        end

        def __getobj__
          @directory
        end

        def each
          yield @directory
        end
      end

      class Listing < Pathname
        def bitmap?
          return sample[0,2] == "MB"
        end

        def copy_to(destination)
          ::FileUtils.cp(self, destination)
        end

        alias_method :extension, :extname
        alias_method :ext, :extname

        def gif?
          return sample[0,4] == "GIF8"
        end

        def image?
          bitmap? || gif? || jpeg?
        end

        def jpeg?
          return sample[0,4] == "\xff\xd8\xff\xe0"
        end

        def sample
          @sample ||= begin
            f = ::File.open(self.to_s, 'rb')
            result = f.read(9)
            f.close
            result
          end
        end
      end
    end
  end
end
