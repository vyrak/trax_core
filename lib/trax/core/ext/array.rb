class Array
  #inspired by: http://thepugautomatic.com/2014/11/array-to-proc-for-hash-access/
  def to_proc
    ->(hash_or_object) {
      if hash_or_object.is_a?(::Hash)
        length == 1 ? hash_or_object[first] : hash_or_object.values_at(*self)
      else
        length == 1 ? hash_or_object.__send__(first) : self.each_with_object({}){ |method_name,result|
                                                         result[method_name] = hash_or_object.__send__(method_name)
                                                       }
      end
    }
  end

  def flat_compact_uniq!
    self.flatten!
    self.compact!
    self.uniq!
    self
  end
  alias :flatten_compact_uniq! :flat_compact_uniq!
end
