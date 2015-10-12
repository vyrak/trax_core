require 'rubygems'
require 'bundler'
require 'simplecov'
require 'trax_core'

SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.before(:suite) do
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered
end

Bundler.require(:default, :development, :test)

::Dir["#{::File.dirname(__FILE__)}/support/*.rb"].each {|f| require f }
