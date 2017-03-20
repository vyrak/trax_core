module Trax
  module Core
    module Types
      class EnumValue
        def self.display_name
          self.to_s
        end

        def self.as_json(options={})
          tag.to_s
        end

        def self.enum
          parent
        end

        def self.to_s
          tag.to_s
        end

        def self.to_sym
          tag
        end

        def self.to_i
          value
        end

        def self.is_enum_value?(val)
          val == parent
        end

        def self.[](attribute_name)
          attributes[attribute_name]
        end

        def self.to_schema
          ::Trax::Core::Definition.new(
            :source => self.name,
            :name => to_s,
            :type => :enum_value,
            :integer_value => to_i,
            :attributes => attributes
          )
        end

        def self.inspect
          tag ? ":#{tag}" : super
        end

        def self.include?(val)
          self.=== val
        end

        #maybe this is a bad idea, not entirely sure
        def self.==(val)
          self.=== val
        end

        def self.===(val)
          [::Trax::Core::Types::Enum, tag, to_s, to_i].include?(val)
        end
      end
    end
  end
end
