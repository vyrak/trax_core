# module Trax
#   module Core
#     class Definition < ::Hashie::Dash
#       include ::Hashie::Extensions::Dash::IndifferentAccess
#
#       property :type, :required => true
#       property :fields, :required => true
#       property :source, :required => true
#       property :name, :required => true
#     end
#   end
# end

module Trax
  module Core
    class Definition
      attr_reader :source, :name, :type

      def initialize(source:,name:,type:, **options)
        @source = source
        @name = name
        @type = type

        options.each_pair do |k,v|
          self.class.__send__(:attr_reader, k)
          instance_variable_set("@#{k}", v)
        end
      end
    end
  end
end
