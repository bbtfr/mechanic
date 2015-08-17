class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user_session, :current_user
  before_filter :authenticate!

  private

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def authenticate!
      if !current_user_session || !current_user
        session[:original_url] = request.original_url
        redirect_to new_user_session_path
      elsif !current_user.mobile_confirmed
        session[:original_url] = request.original_url
        redirect_to new_user_path
      else
        session[:original_url] = nil if session[:original_url]
      end
    end
end
