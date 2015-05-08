class Is
  def self.numeric?(val)
    val.is_a?(::Numeric)
  end

  def self.symbolic?(val)
    val.is_a?(::String) || val.is_a?(::Symbol)
  end
end
