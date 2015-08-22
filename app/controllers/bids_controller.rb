class BidsController < ApplicationController
  def new
    @order = Order.find(params[:order_id])
    @bid = @order.bids.new
  end
end
