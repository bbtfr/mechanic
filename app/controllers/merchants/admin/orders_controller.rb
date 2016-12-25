class Merchants::Admin::OrdersController < Merchants::Admin::ApplicationController
  before_action :find_order, except: [ :index ]

  def index
    @state = if %w(pendeds paids workings settleds refundeds revieweds closeds).include? params[:state]
        params[:state].to_sym
      else
        :pendeds
      end
    @orders = order_klass.send(@state)
  end

  def close
    @order.close!
    flash[:notice] = "订单标记为已结算！"
    redirect_to current_order_path
  end

  private

    def current_order_path
      merchants_admin_order_path(@order)
    end

    def find_order
      @order = order_klass.find(params[:id])
    end

    def order_klass
      Order.where(user_id: current_store)
    end
end
