class Array
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
end

#inspired by: http://thepugautomatic.com/2014/11/array-to-proc-for-hash-access/
