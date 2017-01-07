class Merchants::Admin::MerchantsController < Merchants::Admin::ApplicationController
  before_action :find_merchant, except: [ :index, :new, :create ]

  def index
    @merchants = merchant_klass.all
  end

  def new
    @merchant = merchant_klass.new
  end

  def create
    @merchant = merchant_klass.new(merchant_params)
    @merchant.skip_send_verification_code
    if @merchant.save
      redirect_to merchants_admin_merchants_path
    else
      render :new
    end
  end

  def update
    if @merchant.update_attributes(merchant_params)
      redirect_to merchants_admin_merchants_path
    else
      render :edit
    end
  end

  def active
    @merchant.active!
    redirect_to_referer!
  end

  def inactive
    @merchant.inactive!
    redirect_to_referer!
  end

  private

    def find_merchant
      @merchant = merchant_klass.find(params[:id])
    end

    def merchant_klass
      Merchant.where(user_id: current_store)
    end

    def merchant_params
      params.require(:merchant).permit(:mobile, :nickname, :address, :password,
        :password_confirmation, :role)
    end
end
