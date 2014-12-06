require 'active_support/all'
require_relative './array'

module Trax
  module Core
    extend ::ActiveSupport::Autoload

    autoload :EagerAutoloadNamespace
  end
end
