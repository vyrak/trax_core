class Symbol
  def is_ivar?
    id2name.starts_with?("@")
  end
  alias :ivar? :is_ivar?
end
