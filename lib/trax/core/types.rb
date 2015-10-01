module Trax
  module Core
    module Types
      extend ::ActiveSupport::Autoload

      autoload :Enum
      autoload :EnumValue
      autoload :Struct
      autoload :String
      autoload :ValueObject
    end
  end
end
