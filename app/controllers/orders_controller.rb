class OrdersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :authenticate!, only: [ :notify ]
  before_filter :find_order, except: [ :index, :new, :create, :notify ]
  before_filter :redirect_pending, only: [ :new, :create ]
  before_filter :redirect_mechanic, only: [ :update, :confirm ]

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

  def cancel
    @order.cancel!
    flash[:notice] = "已取消订单！"
    redirect_to new_order_path(@order)
  end

  def pay
    @order_params, response = Weixin.payment current_user, @order, request.remote_ip
    if @order_params
      flash.now[:notice] = "正在创建支付订单..."
    else
      @order.pay! if response["err_code"] == "ORDERPAID"
      flash[:error] = response["return_msg"]
      redirect_to order_path(@order)
    end
  end

  def notify
    result = Hash.from_xml(request.body.read)["xml"]

    if WxPay::Sign.verify?(result)
      # find your order and process the post-paid logic.
      Order.find(params[:id]).pay!
      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def result
    if @order.paid?
      flash[:success] = "成功支付订单！"
      redirect_to order_path(@order)
    else
      flash.now[:notice] = "正在查询订单支付结果..."
    end
  end

  def refund
    if @order.paid?
      response = Weixin.refund @order
      if response.success?
        flash[:notice] = "退款申请已提交，支付款将在3个工作日内退回您的账户..."
        @order.refund!
      else
        flash[:error] = response["return_msg"]
      end
      redirect_to order_path(@order)
    else
      flash[:error] = "订单状态错误！"
      redirect_to order_path(@order)
    end
  end

  def work
    @order.work!
    render :show
  end

  def finish
    if @order.update_attributes(finish_order_params)
      @order.finish!
      flash[:success] = "成功提交完工信息！<br>等待用户确认..."
      redirect_to order_path(@order)
    else
      render :show
    end
  end

  def confirm
    @order.confirm!
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

    def redirect_user
      unless current_user.is_mechanic
        flash[:error] = "商户无法进行此操作！"
        redirect_to orders_path
      end
    end

    def redirect_mechanic
      if current_user.is_mechanic
        flash[:error] = "技师无法进行此操作！"
        redirect_to orders_path
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
        :brand_id, :series_id, :quoted_price, :remark, :lbs_id, :professionality,
        :timeliness, :review)
    end

    def finish_order_params
      params.require(:order).permit(:mechanic_attach_1, :mechanic_attach_2)
    end
end
