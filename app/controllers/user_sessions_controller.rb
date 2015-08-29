class UserSessionsController < ApplicationController
  skip_before_filter :authenticate!

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params)
    @user = User.where(mobile: user_session_params[:mobile]).first_or_initialize

    if params.key? "verification_code"
      if @user.persisted? || @user.save
        flash[:notice] = "验证码已发送，请稍等片刻..."
        @user.reset_verification_code! unless @user.new_record?
        SMSMailer.confirmation(@user).deliver
      else
        @user_session.errors.add(:mobile, @user.errors[:mobile].last)
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
