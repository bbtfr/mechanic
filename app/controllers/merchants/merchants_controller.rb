class Merchants::MerchantsController < Merchants::ApplicationController
  before_filter :authenticate!, except: [ :new, :create, :forget_password, :verification_code, :confirm ]
  before_filter :find_merchant, only: [ :show, :edit, :update, :password, :update_password ]

  def new
    @merchant = Merchant.new
    @merchant.build_store
  end

  def create
    @merchant = Merchant.new(merchant_params)
    if @merchant.save
      render :verification_code
    else
      render :new
    end
  end

  def forget_password
    set_redirect :password, password_merchants_merchant_path
    @merchant = Merchant.new
  end

  def verification_code
    mobile = session[:mobile] || params[:merchant][:mobile] rescue nil
    @merchant = Merchant.where(mobile: mobile).first_or_initialize
    if @merchant.persisted?
      if @merchant.reset_verification_code!
        flash.now[:notice] = "短信验证码已发送，请注意查收"
        session[:mobile] = nil
        render :verification_code
      else
        render :forget_password
      end
    else
      @merchant.errors.add :base, "手机号码未注册"
      render :forget_password
    end
  end

  def confirm
    @merchant = Merchant.where(verification_code_params).first_or_initialize
    if @merchant.persisted?
      @merchant.confirm!

      merchant_session = MerchantSession.new(@merchant)
      merchant_session.save

      redirect! :password, merchants_root_path
      clear_redirect :password
    else
      @merchant.errors.add :base, "验证码错误"
      render :verification_code
    end
  end

  def update
    if @merchant.update_attributes(merchant_params)
      redirect_to merchants_root_path
    else
      render :edit
    end
  end

  def update_password
    if @merchant.valid_password?(merchant_params[:current_password])
      if @merchant.update_attributes(merchant_params)
        flash[:success] = "修改密码成功"
        redirect_to merchants_root_path
      else
        render :password
      end
    else
      @merchant.errors.add :current_password, "错误"
      render :password
    end
  end

  private

    def find_merchant
      @merchant = current_merchant
    end

    def merchant_params
      params.require(:merchant).permit(:mobile, :nickname, :address, :password, :password_confirmation,
        :current_password, store_attributes: [:nickname, :qq])
    end

    def verification_code_params
      params.require(:merchant).permit(:mobile, :verification_code)
    end

end
