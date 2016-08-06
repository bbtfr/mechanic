class Admin::AdministratorsController < Admin::ApplicationController
  skip_before_action :authenticate!, only: [ :forget_password, :verification_code, :confirm ]
  before_action :find_admin, only: [ :show, :edit, :update, :password, :update_password ]

  def index
    @admins = Administrator.all
  end

  def new
    @admin = Administrator.new
  end

  def create
    @admin = Administrator.new(admin_params)
    @admin.skip_send_verification_code
    if @admin.save
      redirect_to admin_administrators_path
    else
      render :new
    end
  end

  def active
    @admin.active!
    redirect_to request.referer
  end

  def inactive
    @admin.inactive!
    redirect_to request.referer
  end

  def forget_password
    set_redirect :password, password_admin_administrator_path
    @admin = Administrator.new
  end

  def verification_code
    mobile = session[:mobile] || params[:administrator][:mobile]
    @admin = Administrator.where(mobile: mobile).first_or_initialize
    if @admin.persisted?
      if @admin.reset_verification_code!
        flash.now[:notice] = "短信验证码已发送，请注意查收"
        session[:mobile] = nil
        render :verification_code
      else
        render :forget_password
      end
    else
      @admin.errors.add :base, "手机号码未注册"
      render :forget_password
    end
  rescue
    redirect_to forget_password_admin_administrator_path
  end

  def confirm
    @admin = Administrator.where(verification_code_params).first_or_initialize
    if @admin.persisted?
      @admin.confirm!

      admin_session = AdministratorSession.new(@admin)
      admin_session.save

      session[:verification_code] = true
      redirect! :password, admin_root_path
      clear_redirect :password
    else
      @admin.errors.add :verification_code, "错误"
      render :verification_code
    end
  end

  def update
    if @admin.update_attributes(admin_params)
      redirect_to admin_administrators_path
    else
      render :edit
    end
  end

  def update_password
    if session[:verification_code] || @admin.valid_password?(admin_params[:current_password])
      if @admin.update_attributes(admin_params)
        session[:verification_code] = nil
        flash[:success] = "修改密码成功"
        redirect_to admin_root_path
      else
        render :password
      end
    else
      @admin.errors.add :current_password, "错误"
      render :password
    end
  end

  private

    def find_admin
      @admin = if params[:id]
          Administrator.find(params[:id])
        else
          current_admin
        end
    end

    def admin_params
      params.require(:administrator).permit(:mobile, :nickname, :password, :password_confirmation,
        :current_password)
    end

    def verification_code_params
      params.require(:administrator).permit(:mobile, :verification_code)
    end

end
