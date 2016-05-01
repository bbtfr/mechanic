class OrdersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :authenticate!, only: [ :notify ]
  before_filter :find_order, except: [ :index, :new, :create, :notify ]
  before_filter :redirect_pending, only: [ :new, :create ]
  before_filter :redirect_mechanic, only: [ :update, :confirm ]

  helper_method :order_klass

  def index
    @state = if %w(paids workings settleds).include? params[:state]
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

  def update_review
    if @order.update_attributes(review_order_params)
      @order.review!
      redirect_to order_path(@order)
    else
      render :review
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
      @order.pay! :weixin if response["err_code"] == "ORDERPAID"
      flash[:error] = "微信支付：#{response["err_code_des"]}"
      redirect_to order_path(@order)
    end
  end

  def notify
    notify_params = Hash.from_xml(request.body.read)["xml"]

    if WxPay::Sign.verify?(notify_params)
      # find your order and process the post-paid logic.
      Order.find(params[:id]).pay! :weixin, notify_params[:transaction_id]
      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def result
    return if params[:format] == "js"
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
        flash[:error] = "微信支付：#{response["err_code_des"]}"
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
    if !params.key?(:order) || @order.update_attributes(finish_order_params)
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
      if current_user.mechanic?
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
      if current_user.client?
        flash[:error] = "车主无法进行此操作！"
        redirect_to orders_path
      end
    end

    def redirect_mechanic
      if current_user.mechanic?
        flash[:error] = "技师无法进行此操作！"
        redirect_to orders_path
      end
    end

    def find_order
      @order = order_klass.find(params[:id])
    end

    def order_klass
      if current_user.mechanic?
        Order.where(mechanic_id: current_user.mechanic)
      else
        Order.where(user_id: current_user)
      end
    end

    def order_params
      params.require(:order).permit(:address, :appointment, :skill_cd,
        :brand_cd, :series_cd, :quoted_price, :remark, :lbs_id)
    end

    def review_order_params
      params.require(:order).permit(:professionality, :timeliness, :review)
    end

    def finish_order_params
      params.require(:order).permit(:mechanic_attach_1, :mechanic_attach_2)
    end
end
