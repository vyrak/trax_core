class EnumValue < SimpleDelegator
  def initialize(val)
    @value = val
  end

  def __getobj__
    @value
  end
end
