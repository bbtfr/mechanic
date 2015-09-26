class Admin::MerchantsController < Admin::ApplicationController
  before_filter :find_merchant, except: [ :index, :confirmed ]

  def index
    @merchants = Store.merchants.unconfirmeds
  end

  def confirmed
    @confirmed = true
    @merchants = Store.merchants.confirmeds
  end

  def confirm
    @merchant.confirm!
    redirect_to request.referer
  end

  def destroy
    @merchant.destroy
    redirect_to request.referer
  end

  private

    def find_merchant
      @merchant = Store.find(params[:id])
    end
end
