class Array
  def to_proc
    ->(h) { length == 1 ? h[first] : h.values_at(*self) }
  end
end

#credit: http://thepugautomatic.com/2014/11/array-to-proc-for-hash-access/
