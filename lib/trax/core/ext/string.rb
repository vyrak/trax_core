class String
  def symbolize
    self.try_chain(:demodulize, :underscore, :to_sym)
  end

  def translate(*args)
    I18n.translate(self.underscore, *args)
  end

  def translate_words
    self.split(" ").map(&:translate).join(" ")
  end
end
