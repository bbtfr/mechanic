class Admin::ApplicationController < ActionController::Base
  include RedirectionHelper

  layout "admin"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_admin_session, :current_admin
  before_action :authenticate!

  private

    def current_admin_session
      return @current_admin_session if defined?(@current_admin_session)
      @current_admin_session = AdministratorSession.find
    end

    def current_admin
      return @current_admin if defined?(@current_admin)
      @current_admin = current_admin_session && current_admin_session.administrator
    end

    def authenticate!
      if !current_admin_session || !current_admin
        set_redirect_original_url :authenticate
        redirect_to new_admin_administrator_session_path
      else
        clear_redirect :authenticate
      end
    end

    def redirect_user
      if current_merchant.user?
        flash[:error] = "派单人员无法访问此页面！"
        redirect_to merchants_root_path
      end
    end

end
