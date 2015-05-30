class EnumValue < SimpleDelegator
  attr_accessor :name, :value

  def initialize(name:, value:)
    @name = name
    @value = value
  end

  def __getobj__
    @value
  end

  def inspect
    @name.to_s
  end

  def to_json
    @value
  end

  def to_s
    @name
  end

  def ===(val)
    [name.to_s, value.to_i].include?(val)
  end

  alias :to_i :value
end
