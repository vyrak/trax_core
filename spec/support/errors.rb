module Errors
  class SiteBrokenError < ::Trax::Core::Errors::Base
    argument :request_url, :required => true
    argument :request_id, :required => true

    message {
      "Oh no, the site broke on #{request_url}" \
      "for current_request_id #{request_id}!"
    }
  end
end
