class BidsController < ApplicationController
  before_filter :find_order
  before_filter :find_bid, only: :show

  def new
    @bid = bid_klass.new
  end

  def create
    klass = bid_klass.where(mechanic_id: current_user.mechanic_id)
    @bid = klass.first || klass.new(bid_params)
    if @bid.persisted? || @bid.save
      flash[:success] = "竞价成功，顾客正在选人..."
      redirect_to order_bid_path(@order.id, @bid.id)
    else
      render :new
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
