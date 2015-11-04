module Trax
  module Core
    class PathPermutations < SimpleDelegator
      include ::Enumerable

      def initialize(*args, current_path_segments:[])
        _current = args.shift
        current_path_segments << [current_path_segments.last, _current].compact

        @paths = if args.length > 0
          self.class.new(*args, current_path_segments: current_path_segments)
        else
          current_path_segments.map!{ |segs| segs.join("/") }
        end
        
        @paths
      end

      def __getobj__
        @paths
      end
    end
  end
end
