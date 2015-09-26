class Merchants::OrdersController < Merchants::ApplicationController
  skip_before_filter :verify_authenticity_token, :authenticate!, only: [ :notify ]
  before_filter :find_order, except: [ :index, :new, :create, :notify ]
  before_filter :redirect_pending, only: [ :new, :create, :index ]

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
  end

  def create
    @order = order_klass.new(order_params)
    if @order.save
      if @order.pending?
        redirect_to merchants_order_bids_path(@order)
      elsif @order.paying?
        redirect_to pay_merchants_orders_path(@order)
      end
    else
      render :new
    end
  end

  def update
    if @order.update_attributes(order_params)
      @order.review!
      redirect_to merchants_order_path(@order)
    else
      render :new
    end
  end

  def cancel
    @order.cancel!
    flash[:notice] = "已取消订单！"
    redirect_to new_merchants_order_path(@order)
  end

  def pay
    response = Weixin.payment_qrcode @order
    if response.success?
      @code_url = response["code_url"]
      flash.now[:notice] = "正在创建支付订单..."
    else
      @order.pay! if response["err_code"] == "ORDERPAID"
      flash[:error] = response["return_msg"]
      redirect_to merchants_order_path(@order)
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

  def confirm
    @order.confirm!
    render :show
  end

  private

    def redirect_pending
      if order = order_klass.pendings.first
        flash[:notice] = "您有一条竞价中的订单..."
        redirect_to merchants_order_bids_path(order)
      elsif order = order_klass.confirmings.first
        flash[:notice] = "您有一条需要确认完工的订单..."
        redirect_to merchants_order_path(order)
      end
    end

    def find_order
      @order = order_klass.find(params[:id])
    end

    def order_klass
      Order.where(user_id: current_merchant.store, merchant_id: current_merchant)
    end

    def order_params
      params.require(:order).permit(:address, :appointment, :skill_id,
        :brand_id, :series_id, :quoted_price, :remark, :lbs_id, :professionality,
        :timeliness, :review, :contact_mobile, :contact_nickname, :mechanic_id)
    end

end
