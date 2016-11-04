module MethodExtensions
  # method(method_name).parameters returns an array of the parameters it accepts as well as the signature type
  # :req = required, ordinal argument, i.e. def foo(one)
  # :opt = optional ordinal argument, i.e. def foo(one=nil)
  # :keyreq = required keyword argument i.e. def foo(req:)
  # :key = optional keyword argument, i.e. def foo(one:nil)
  # :rest = optional arguments splat, i.e. def foo(*args)
  # :keyrest = optional keyword arguments splat, i.e. def foo(**args)

  def accepted_argument_signatures
    @accepted_argument_signatures ||= self.parameters.any? ? self.parameters.map(&:first).uniq : []
  end

  def accepts_something?
    @accepts_something ||= arity != 0
  end

  def accepts_arguments?
    @accepts_arguments ||= requires_arguments? || accepts_optional_arguments? || accepts_arguments_splat?
  end

  def accepts_keywords?
    @accepts_keywords ||= requires_keywords? || accepts_optional_keywords? || accepts_keywords_splat?
  end

  def accepts_arguments_splat?
    @accepts_arguments_splat ||= accepted_argument_signatures.include?(:rest)
  end

  def accepts_keywords_splat?
    @accepts_keywords_splat ||= accepted_argument_signatures.include?(:keyrest)
  end

  def accepts_optional_arguments?
    @accepts_optional_arguments ||= accepted_argument_signatures.include?(:opt)
  end

  def accepts_optional_keywords?
    @accepts_optional_keywords ||= accepted_argument_signatures.include?(:key)
  end

  def requires_arguments?
    @requires_arguments ||= accepted_argument_signatures.include?(:req)
  end

  def requires_keywords?
    @requires_keywords ||= accepted_argument_signatures.include?(:keyreq)
  end
end

class Method
  include MethodExtensions
end
