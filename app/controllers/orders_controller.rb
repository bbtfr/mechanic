class OrdersController < ApplicationController
  before_filter :find_order, except: [ :index, :new, :create ]
  before_filter :redirect_pending, only: [ :new, :create ]
  before_filter :redirect_owner, only: [ :update ]

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
    # @order_params = Weixin.payment current_user, @order, request.remote_ip
    # if @order_params
    #   flash[:notice] = "正在创建支付订单..."
    # else
    #   flash[:error] = "支付订单创建失败，请稍后再试..."
    # end
    @order.pay
    redirect_to result_order_path(@order)
  end

  def result
    if @order.paid?
      flash[:success] = "成功支付订单！"
      redirect_to order_path(@order)
    else
      flash[:notice] = "正在查询订单支付结果..."
    end
  end

  def work
    @order.work
    render :show
  end

  def finish
    if @order.update_attributes(finish_order_params)
      flash[:success] = "成功提交完工信息！<br>等待用户确认..."
      @order.finish
      redirect_to order_path(@order)
    else
      render :show
    end
  end

  def confirm
    @order.confirm
    render :show
  end

  private

    def redirect_pending
      if current_user.is_mechanic
        flash[:notice] = "技师无法创建预约订单..."
        redirect_to orders_path
      elsif order = order_klass.pendings.first
        flash[:notice] = "您有一条竞价中的订单..."
        redirect_to order_bids_path(order)
      elsif order = order_klass.confirmings.first
        flash[:notice] = "您有一条需要确认完工的订单..."
        redirect_to order_path(order)
      end
    end

    def redirect_owner
      if current_user != @order.user
        flash[:error] = "订单所有权错误！"
        redirect_to order_path(@order)
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
      params.require(:order).permit(:address, :appointment, :skill_id,
        :brand_id, :series_id, :quoted_price, :remark, :adcode, :professionality,
        :timeliness, :review)
    end

    def finish_order_params
      params.require(:order).permit(:mechanic_attach_1, :mechanic_attach_2)
    end
end
