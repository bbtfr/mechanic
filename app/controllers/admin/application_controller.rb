class Admin::ApplicationController < ActionController::Base
  include RedirectionHelper

  layout "admin"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  Config = YAML.load(ERB.new(File.read("#{Rails.root}/config/admin.yml")).result)[Rails.env]
  http_basic_authenticate_with name: Config["username"], password: Config["password"]

end
