# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
end

run Rack::URLMap.new(
  '/'         => Rails.application,
  '/sidekiq'  => Sidekiq::Web
)
