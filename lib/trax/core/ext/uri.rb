module URIExtensions
  def join(*args)
    self + args.map{ |arg| arg.is_a?(::String) ? arg : arg.to_s }.join("/")
  end
end

class URI::Generic
  include URIExtensions
end
