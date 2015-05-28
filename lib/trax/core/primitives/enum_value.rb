class EnumValue < SimpleDelegator
  attr_accessor :name, :value

  def initialize(name:, value:)
    @name = name
    @value = value
  end

  def __getobj__
    @value
  end

  def to_json
    @value.to_i
  end

  def to_s
    @name
  end

  alias :to_i :value
end
