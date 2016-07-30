class Admin::OrdersController < Admin::ApplicationController
  before_action :find_order, except: [ :index ]

  def index
    @orders = if params[:mechanic_id]
        @mechanic = Mechanic.where(user_id: params[:mechanic_id]).first!
        @mechanic.orders
      elsif params[:merchant_id]
        @merchant = Merchant.where(user_id: params[:merchant_id]).first!
        @merchant.orders
      else
        Order.all
      end
  end

  private

    def find_order
      @order = Order.find(params[:id])
    end
end
