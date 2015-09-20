class Merchants::BidsController < Merchants::ApplicationController
  before_filter :find_order
  before_filter :find_bid, only: [ :show, :pick ]

  def pick
    if @order.pick!(@bid)
      flash[:success] = "成功选中技师！"
      redirect_to pay_merchants_orders_path @order
    else
      flash.now[:error] = "订单已失效..."
      render :show
    end
  end

  private

    def find_order
      @order = Order.find(params[:order_id])
    end

    def find_bid
      @bid = bid_klass.find(params[:id])
    end

    def bid_klass
      Bid.where(order_id: params[:order_id])
    end

    def bid_params
      params.require(:bid).permit(:markup_price)
    end
end
