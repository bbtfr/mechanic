class UserSessionsController < ApplicationController
  skip_before_filter :authenticate!

  def new
    new_weixin
    @user_session = UserSession.new
  end

  def new_weixin
    return unless weixin?
    if params.key? "code"
      @openid = Weixin.get_oauth_access_token(params["code"]).result["openid"]
      user = User.where(weixin_openid: @openid).first
      if user && user.mobile_confirmed
        UserSession.create(user)
        redirect_to session[:original_url] || root_path
      end
    else
      redirect_to Weixin.authorize_url(request.url)
    end
  end

  def create
    @user_session = UserSession.new(user_session_params)
    @user = User.where(mobile: user_session_params[:mobile]).first_or_initialize

    if params.key? "verification_code"
      if @user.persisted? ? @user.reset_verification_code! : @user.save
        flash.now[:notice] = "验证码已发送，请稍等片刻..."
      else
        flash.now[:error] = @user.errors.full_messages.last
      end
      render :new
    else
      if @user_session.save
        @user.confirm_mobile!
        redirect_to session[:original_url] || root_path
      else
        render :new
      end
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to new_user_session_path
  end
  alias_method :delete, :destroy

  private

    def user_session_params
      params.require(:user_session).permit(:mobile, :verification_code, :weixin_openid)
    end
end
