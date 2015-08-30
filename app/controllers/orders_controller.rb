class OrdersController < ApplicationController
  before_filter :find_order, only: [ :show, :review, :update, :pay ]
  before_filter :redirect, only: [ :new, :create ]

  def index
    @state = if %w(pendings paids workings finisheds).include? params[:state]
        params[:state].to_sym
      else
        :paids
      end
    @orders = order_klass.send(@state)
  end

  def new
    @order = order_klass.new
    @order.address ||= current_user.address
  end

  def create
    @order = order_klass.new(order_params)
    if @order.save
      SendOrderTemplateMessageJob.perform_later @order
      redirect_to order_bids_path(@order)
    else
      render :new
    end
  end

  def update
    if @order.update_attributes(order_params)
      redirect_to order_path(@order)
    else
      render :new
    end
  end

  def pay
    @order_params = Weixin.payment current_user, @order, request.remote_ip
    if @order_params
      flash[:notice] = "正在创建支付订单..."
    else
      flash[:error] = "支付订单创建失败，请稍后再试..."
    end
  end

  private

    def redirect
      if current_user.is_mechanic
        flash[:notice] = "技师无法创建预约订单..."
        redirect_to orders_path
      else
        order = order_klass.pendings.first
        redirect_to order_bids_path(order) if order
      end
    end

    def find_order
      @order = order_klass.find(params[:id])
    end

    def order_klass
      if current_user.is_mechanic
        Order.where(mechanic_id: current_user.mechanic_id)
      else
        Order.where(user_id: current_user)
      end
    end

    def order_params
      params.require(:order).permit(:user_id, :mechanic_id, :address, :appointment,
        :skill_id, :brand_id, :series_id, :quoted_price, :remark, :adcode)
    end
end
