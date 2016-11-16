class Class
  def detect_in_chain(bottom_klass = self, &block)
    result = bottom_klass.instance_eval(&block)
    return result if result
    detect_in_chain(bottom_klass.superclass, &block)
  end

  def superclasses_until(klass, bottom_klass=self, superclass_chain = [])
    if bottom_klass.superclass != klass
      superclass_chain.unshift(bottom_klass.superclass)
      return superclasses_until(klass, bottom_klass.superclass, superclass_chain)
    else
      return superclass_chain
    end
  end
end
