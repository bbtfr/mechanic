class Merchants::Admin::MerchantsController < Merchants::Admin::ApplicationController
  before_filter :find_merchant, only: [ :show, :edit, :update, :destroy ]

  def index
    @merchants = merchant_klass.all
  end

  def new
    @merchant = merchant_klass.new
  end

  def create
    @merchant = merchant_klass.new(merchant_params)
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
      render :new
    end
  end

  def destroy
    @merchant.destroy
    redirect_to merchants_admin_merchants_path
  end

  private

    def find_merchant
      @merchant = merchant_klass.find(params[:id])
    end

    def merchant_klass
      Merchant.where(user_id: current_merchant.store)
    end

    def merchant_params
      params.require(:merchant).permit(:mobile, :nickname, :address, :password, :password_confirmation)
    end
end
