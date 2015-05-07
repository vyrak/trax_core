module Enumerable
  def group_by_count
    ::Hash.new(0).tap{|hash| each{|item| hash[item] += 1 } }
  end
end
