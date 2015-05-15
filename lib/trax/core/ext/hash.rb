class Hash
  ## Returns selected keys, named or renamed as specified
  # myproduct = {:name => "something", :price => "20"}
  # myproduct.tap(&{:price => :cost})
  ## Note: Tap only works where source is a hash object, so use as otherwise
  # (because tap always returns the object you are tapping)
  # myproduct = ::OpenStruct.new({:name => "something", :price => "20"})
  # myproduct.as(&{:price => :cost})

  def to_proc
    ->(hash_or_object) {
      new_hash = {}

      if hash_or_object.is_a?(::Hash)
        self.each_pair do |k,v|
          if v.is_a?(Hash)
            new_hash[v.keys.first] = v.values.first.call(hash_or_object[k])
          else
            new_hash[v] = hash_or_object[k]
          end
        end

        hash_or_object.keys.map{ |k| hash_or_object.delete(k) }
        hash_or_object.merge!(new_hash)
      else
        self.each_pair do |k,v|
          if v.is_a?(Hash)
            new_hash[v.keys.first] = v.values.first.call(hash_or_object.__send__(k))
          else
            new_hash[v] = hash_or_object.__send__(k)
          end
        end
      end

      return new_hash
    }
  end
end
