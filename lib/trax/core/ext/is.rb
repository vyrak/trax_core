class Is
  def self.truthy?(val)
    [TrueClass, FalseClass].include?(val)
  end

  def self.numeric?(val)
    val.is_a?(::Numeric)
  end

  def self.string?(val)
    val.is_a?(::String)
  end

  def self.symbol?(val)
    val.is_a?(::Symbol)
  end

  def self.symbolic?(val)
    val.is_a?(::String) || val.is_a?(::Symbol)
  end
end
