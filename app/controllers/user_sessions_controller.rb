class UserSessionsController < ApplicationController
  skip_before_filter :authenticate!

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params)

    if params.has_key? "verification_code"
      user = User.first_or_create(mobile: user_session_params[:mobile])
      user.reset_verification_code! unless user.new_record?
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

  private

    def user_session_params
      params.require(:user_session).permit(:mobile, :verification_code, :is_mechanic)
    end
end
