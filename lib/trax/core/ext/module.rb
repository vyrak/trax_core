class Module
  def module_attribute(*attribute_names, &block)
    attribute_names.each do |_attribute_name|
      singleton_class.__send__("attr_accessor", _attribute_name)
      instance_variable_set("@#{_attribute_name}", block.call) if block_given?
    end
  end

  def recursively_define_namespaced_class(class_name, class_to_inherit_from = Object)
    paths = class_name.split("::")
    const_name = paths.shift

    if paths.length > 0
      self.const_set(const_name, ::Module.new) unless self.constants.include?(:"#{const_name}")
      "#{self.name}::#{const_name}".safe_constantize.recursively_define_namespaced_class(paths.join("::"), class_to_inherit_from)
    else
      self.const_set(const_name, ::Class.new(class_to_inherit_from)) unless self.constants.include?(:"#{const_name}")
    end
  end
end
