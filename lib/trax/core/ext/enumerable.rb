module Enumerable
  def group_by_count
    ::Hash.new(0).tap{|hash| each{|item| hash[item] += 1 } }
  end

  def group_by_uniq
    each_with_object({}) do |value, hash|
      key = yield value
      raise "Multiple values for key #{key}!" if hash.key?(key)
      hash[key] = value
    end
  end
end
