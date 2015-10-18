class Merchants::Admin::OrdersController < Merchants::Admin::ApplicationController
  before_filter :find_order, except: [ :index ]

  def index
    @orders = order_klass.settleds
  end

  private

    def find_order
      @order = order_klass.find(params[:id])
    end

    def order_klass
      Order.where(user_id: current_merchant.store)
    end
end
