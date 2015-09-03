class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user_session, :current_user, :weixin?
  before_filter :ensure_weixin_openid!
  before_filter :authenticate!

  private

    def weixin?
      request.user_agent.include? "MicroMessenger"
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def authenticate!
      if !current_user_session || !current_user || !current_user.mobile_confirmed
        session[:original_url] = request.original_url
        redirect_to new_user_session_path
      elsif current_user.invalid?
        session[:original_url] = request.original_url
        redirect_to new_user_path
      else
        session[:original_url] = nil if session[:original_url]
      end
    end

    def ensure_weixin_openid!
      if request.get? && weixin? && current_user && !current_user.weixin_openid
        if params.key? "code"
          @openid = Weixin.get_oauth_access_token(params["code"]).result["openid"]
          Weixin.callback_signup_event current_user, @openid
          current_user.update_weixin_openid @openid
        else
          redirect_to Weixin.authorize_url(request.url)
        end
      end
    end
end
