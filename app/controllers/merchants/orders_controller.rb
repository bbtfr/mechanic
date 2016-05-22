class Merchants::OrdersController < Merchants::ApplicationController
  skip_before_filter :verify_authenticity_token, :authenticate!, only: [ :notify ]
  before_filter :find_order, except: [ :index, :new, :create, :notify ]
  before_filter :redirect_pending, only: [ :new, :index ]

  helper_method :fetch_redirect

  def index
    @state = if %w(pendeds paids workings finisheds).include? params[:state]
        params[:state].to_sym
      else
        :pendeds
      end
    @orders = order_klass.send(@state)
  end

  def new
    @order = order_klass.new
  end

  def create
    @order = order_klass.new(order_params)
    if @order.save
      if @order.appointing?
        redirect_to pick_merchants_order_path(@order)
      elsif @order.pending?
        redirect_to merchants_order_bids_path(@order)
      else
        redirect_to current_order_path
      end
    else
      render :new
    end
  end

  def update_pick
    if mechanic_id = params[:order][:mechanic_id]
      remark = params[:order][:remark]
      @order.update_attribute(:remark, remark) if remark
      mechanic = Mechanic.find(mechanic_id)
      if @order.assigned?
        @order.repick! mechanic
      else
        @order.pick! mechanic
      end
      redirect_to current_order_path
    else
      @order.remark = params[:order][:remark]
      @order.errors.add :base, "请选择一个技师"
      render :pick
    end
  end

  def cancel
    @order.cancel!
    flash[:notice] = "订单已取消！"
    redirect_to merchants_root_path
  end

  def pend
    @order.pend!
    flash[:notice] = "订单延后付款！"
    redirect_to merchants_root_path
  end

  def pay
    case params[:format]
    when "alipay"
      response = Ali.payment @order
      redirect_to response
    when "weixin"
      response = Weixin.payment_qrcode @order
      if response.success?
        @code_url = response["code_url"]
        flash.now[:notice] = "正在创建支付订单..."
      else
        @order.pay! :weixin if response["err_code"] == "ORDERPAID"
        flash[:error] = "微信支付：#{response["err_code_des"]}"
        redirect_to merchants_root_path
      end
    else
      flash[:error] = "未知支付类型"
      redirect_to current_order_path
    end
  end

  def notify
    case params[:format]
    when "alipay"
      notify_params = params.except(*request.path_parameters.keys)
      if Alipay::Notify.verify?(notify_params)
        case notify_params[:notify_type]
        when "trade_status_sync"
          Order.find(params[:id]).pay! :alipay, notify_params[:trade_no]
          render nothing: true
        when "batch_refund_notify"
          Order.find(params[:id]).refund!
          render nothing: true
        else
          render text: "未知支付类型", status: 400
        end
      else
        render text: "签名校验失败", status: 400
      end
    when "weixin"
      notify_params = Hash.from_xml(request.body.read)["xml"]

      if WxPay::Sign.verify?(notify_params)
        # find your order and process the post-paid logic.
        Order.find(params[:id]).pay! :weixin, notify_params[:transaction_id]
        render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
      else
        render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
      end
    else
      render text: "未知支付类型", status: 400
    end
  end

  def result
    return if params[:format] == "js"

    notify_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify.verify?(notify_params)
      Order.find(params[:id]).pay! :alipay, notify_params[:trade_no]
    end

    if @order.paid?
      flash[:success] = "成功支付订单！"
      redirect_to merchants_root_path
    else
      flash.now[:notice] = "正在查询订单支付结果..."
    end
  end

  def refund
    if @order.paid? || @order.working? || @order.confirming?
      if @order.paid?
        reason = :user_cancel
      else
        reason = :merchant_revoke
        @order.update_attributes(review_order_params)
      end

      if @order.pay_type_alipay?
        flash[:notice] = "退款申请已提交，等待管理员审核..."
        @order.refunding! reason
      elsif @order.pay_type_weixin?
        response = Weixin.refund @order
        if response.success?
          flash[:notice] = "退款申请已提交，支付款将在3个工作日内退回您的账户..."
          @order.refund! reason
        else
          flash[:error] = "微信支付：#{response["err_code_des"]}"
        end
      elsif @order.price.zero?
        @order.refund! reason
      else
        flash[:error] = "未知支付类型"
      end
    else
      flash[:error] = "订单状态错误！"
    end
    redirect_to current_order_path
  end

  def remark
    set_redirect_referer :remark
  end

  def update_remark
    if @order.update_attributes(remark_order_params)
      redirect! :remark, current_order_path
    else
      render :remark
    end
  end

  def rework
    @order.rework!
    flash[:notice] = "订单申请返工！"
    redirect_to current_order_path
  end

  def confirm
    @order.confirm!
    flash[:notice] = "订单确认完工！"
    redirect_to current_order_path
  end

  def update_review
    if @order.update_attributes(review_order_params)
      @order.review!
      redirect_to current_order_path
    else
      render :review
    end
  end

  private

    def current_order_path
      merchants_order_path(@order)
    end

    def redirect_pending
      if order = unhosting_order_klass.pendings.first
        if order.appointing?
          flash[:notice] = "您有一条需要指派技师的订单..."
          redirect_to merchants_order_path(order)
        else
          flash[:notice] = "您有一条竞价中的订单..."
          redirect_to merchants_order_bids_path(order)
        end
      elsif order = unhosting_order_klass.payings.first
        flash[:notice] = "您有一条需要支付的订单..."
        redirect_to merchants_order_path(order)
      elsif order = unhosting_order_klass.confirmings.first
        flash[:notice] = "您有一条需要确认完工的订单..."
        redirect_to merchants_order_path(order)
      end
    end

    def find_order
      @order = if current_merchant.admin?
          admin_order_klass.find(params[:id])
        else
          order_klass.find(params[:id])
        end
    end

    def admin_order_klass
      Order.where(user_id: current_store)
    end

    def order_klass
      Order.where(user_id: current_store, merchant_id: current_merchant)
    end

    def unhosting_order_klass
      Order.where(user_id: current_store, merchant_id: current_merchant, hosting: false)
    end

    def order_params
      params.require(:order).permit(:address, :appointment, :skill_cd,
        :brand_cd, :series_cd, :quoted_price, :remark, :merchant_remark,
        :custom_location, :lbs_id, :province_cd, :city_cd, :professionality,
        :timeliness, :review, :contact_mobile, :contact_nickname, :hosting,
        :appointing)
    end

    def review_order_params
      params.require(:order).permit(:professionality, :timeliness, :review)
    end

    def remark_order_params
      params.require(:order).permit(:merchant_remark)
    end

end
