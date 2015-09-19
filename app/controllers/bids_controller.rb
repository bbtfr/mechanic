class BidsController < ApplicationController
  before_filter :find_order
  before_filter :find_bid, only: [ :show, :pick ]

  def new
    @bid = bid_klass.new
  end

  def create
    klass = bid_klass.where(mechanic_id: current_user.mechanic)
    @bid = klass.first || klass.new(bid_params)
    if @bid.persisted?
      flash[:notice] = "已经参与过本次竞价，无法修改加价"
      redirect_to order_bid_path(@order, @bid)
    elsif @bid.save
      flash[:success] = "竞价成功，顾客正在选人..."
      redirect_to order_bid_path(@order, @bid)
    else
      render :new
    end
  end

  def pick
    if @order.pick!(@bid)
      flash[:success] = "成功选中技师！"
      redirect_to pay_orders_path @order
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
