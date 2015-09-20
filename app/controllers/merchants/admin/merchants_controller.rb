class Merchants::Admin::MerchantsController < Merchants::Admin::ApplicationController
  before_filter :find_merchant, only: [ :edit, :update ]

  def index
    @merchants = merchant_klass.all
  end

  private

    def find_merchant
      @merchant = merchant_klass.find(params[:id])
    end

    def merchant_klass
      Merchant.where(user_id: current_merchant.store)
    end
end
