module MethodExtensions
  def accepted_argument_signatures
    @accepted_argument_signatures ||= self.parameters.any? ? self.parameters.map(&:first).uniq : []
  end

  def accepts_arguments?
    @accepts_arguments ||= arity != 0
  end

  def accepts_keywords?
    @accepts_keywords ||= accepted_argument_signatures.include?(:opt)
  end

  def accepts_arguments_splat?
    @accepts_arguments_splat ||= accepted_argument_signatures.include?(:rest)
  end
end

class Method
  include MethodExtensions
end
