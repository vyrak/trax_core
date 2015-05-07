class String
  def translate(*args)
    I18n.translate(self.underscore, *args)
  end

  def translate_words
    self.split(" ").map(&:translate).join(" ")
  end
end
