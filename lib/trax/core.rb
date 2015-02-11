require 'active_support/all'
require_relative './array'
require_relative './core/ext/module'
require_relative './core/ext/object'

module Trax
  module Core
    extend ::ActiveSupport::Autoload

    autoload :EagerAutoloadNamespace
    autoload :Errors
  end
end
