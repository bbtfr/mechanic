# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == Administrator::Config['username'] && password == Administrator::Config['password']
end

run Rack::URLMap.new(
  '/'         => Rails.application,
  '/sidekiq'  => Sidekiq::Web
)
