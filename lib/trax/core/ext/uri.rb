module URIExtensions
  def join(*args)
    self + args.join("/")
  end
end

class URI::HTTP
  include URIExtensions
end

class URI::HTTPS
  include URIExtensions
end
