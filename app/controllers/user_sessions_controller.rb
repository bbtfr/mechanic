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
    else
      redirect_to Weixin.authorize_url
    end
  end

  def create
    @user_session = UserSession.new(user_session_params)

    if params.key? "verification_code"
      user = User.where(mobile: user_session_params[:mobile]).first_or_create
      user.update_weixin_openid user_session_params["weixin_openid"]
      user.reset_verification_code! unless user.new_record?
      SMSMailer.confirmation(user).deliver
      flash[:notice] = "验证码已发送，请稍等片刻..."
      render :new
    else
      if @user_session.save
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
