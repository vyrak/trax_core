require 'active_support/all'
require_relative './array'
require_relative './core/ext/module'

module Trax
  module Core
    extend ::ActiveSupport::Autoload

    autoload :EagerAutoloadNamespace
  end
end
