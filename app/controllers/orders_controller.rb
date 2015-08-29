class OrdersController < ApplicationController
  before_filter :find_order, only: [ :show, :review, :update ]

  def index
    @orders = order_klass.all
  end

  def new
    @order = order_klass.new
    @order.address ||= current_user.address
  end

  def create
    @order = order_klass.new(order_params)
    if @order.save
      SendOrderTemplateMessageJob.perform_later @order
      redirect_to order_bids_path(@order.id)
    else
      render :new
    end
  end

  def update
    if @order.update_attributes(order_params)
      redirect_to order_path(@order.id)
    else
      render :new
    end
  end

  def pay
    @order_params = Weixin.payment current_user, @order, request
  end

  private

    def find_order
      @order = order_klass.find(params[:id])
    end

    def order_klass
      if current_user.is_mechanic
        Order.where(mechanic_id: current_user.mechanic_id)
      else
        Order.where(user_id: current_user.id)
      end
    end

    def order_params
      params.require(:order).permit(:user_id, :mechanic_id, :address, :appointment,
        :skill_id, :brand_id, :series_id, :quoted_price, :remark, :adcode)
    end
end
