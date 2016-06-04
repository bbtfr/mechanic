# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
# require 'tailog'

# use Tailog::Eval

# run Rack::URLMap.new(
#   '/'         => Rails.application,
#   '/tailog'   => Tailog::App
# )

run Rails.application
