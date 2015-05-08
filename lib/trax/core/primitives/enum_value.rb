class EnumValue < SimpleDelegator
  attr_accessor :name, :value

  def initialize(name:, value:)
    @name = name
    @value = value
  end

  def __getobj__
    @name
  end
  alias :to_i :value
end
