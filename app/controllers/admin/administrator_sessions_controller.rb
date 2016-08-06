class Admin::AdministratorSessionsController < Admin::ApplicationController
  skip_before_action :authenticate!, except: [ :destroy ]

  def new
    clear_redirect :authenticate
    @admin_session = AdministratorSession.new
  end

  def create
    @admin_session = AdministratorSession.new(admin_session_params)
    if @admin_session.save
      redirect! :authenticate, admin_root_path
    else
      administrator = @admin_session.attempted_record
      if administrator && !administrator.confirmed?
        session[:mobile] = administrator.mobile
        link_url = verification_code_admin_administrator_path
        @admin_session.errors.add :base, "点击这里<a href=\"#{link_url}\">重新发送验证码</a>".html_safe
      end

      render :new
    end
  end

  def destroy
    current_admin_session.destroy
    redirect_to new_admin_administrator_session_path
  end

  private

    def admin_session_params
      params.require(:administrator_session).permit(:mobile, :password)
    end
end
