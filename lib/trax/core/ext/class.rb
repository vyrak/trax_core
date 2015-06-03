class Class
  def self.extend_from_parent_with_hooks(name, parent_klass, &block)
    trace = ::TracePoint.new(:end) do |tracepoint|
      if tracepoint.self.class == Class
        trace.disable

        if parent_klass.instance_variable_defined?(:@_after_inherited_block)
          self.instance_eval(&parent_klass.instance_variable_get(:@_after_inherited_block))
        end
      end
    end

    trace.enable

    const_set(name, new(parent_klass, &block))
  end

  def superclasses_until(klass, superclass_chain = [])
    if superclass != klass
      superclass_chain << superclass
      return superclasses_until(superclass, superclass_chain)
    else
      return superclass_chain
    end
  end
end
