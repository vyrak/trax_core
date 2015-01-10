#stolen from abrandoned https://rubygems.org/gems/try_chain
require "active_support/core_ext/object/try"

class Object
  def try_chain(*symbols)
    return nil if self.nil?

    symbols = symbols.flatten
    symbols.compact!

    symbols.reduce(self) do |result, symbol|
      result = result.try(symbol)
      break nil if result.nil?
      result
    end
  end
end
