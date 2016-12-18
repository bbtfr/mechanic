class Merchants::Admin::RechargesController < Merchants::Admin::ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate!, only: [ :notify ]

  def show
    redirect_to new_merchants_admin_recharges_path
  end

  def new
    @recharge = recharge_klass.new
  end

  def create
    @recharge = recharge_klass.new(recharge_params)
    if @recharge.save
      case params[:format]
      when "alipay"
        response = Ali.recharge @recharge
        redirect_to response
      when "weixin"
        response = Weixin.recharge_qrcode @recharge
        if response.success?
          @code_url = response["code_url"]
          flash.now[:notice] = "正在创建支付订单..."
        else
          @recharge.pay! :weixin if response["err_code"] == "ORDERPAID"
          flash[:error] = "微信支付：#{response["err_code_des"]}"
          redirect_to merchants_root_path
        end
      else
        flash[:error] = "未知支付类型"
        redirect_to new_merchants_admin_recharges_path
      end
    else
      render :new
    end
  end

  def result
    return if params[:format] == "js"

    notify_params = params.except(*request.path_parameters.keys)
    if Alipay::Notify.verify?(notify_params)
      recharge_klass.find(params[:id]).pay! :alipay, notify_params[:trade_no]
    end

    if @order.paid?
      flash[:success] = "成功支付订单！"
      redirect_to merchants_root_path
    else
      flash.now[:notice] = "正在查询订单支付结果..."
    end
  end

  def notify
    case params[:format]
    when "alipay"
      notify_params = params.except(*request.path_parameters.keys)
      if Alipay::Notify.verify?(notify_params)
        case notify_params[:notify_type]
        when "trade_status_sync"
          recharge_klass.find(params[:id]).pay! :alipay, notify_params[:trade_no]
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
        recharge_klass.find(params[:id]).pay! :weixin, notify_params[:transaction_id]
        render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
      else
        render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
      end
    else
      render text: "未知支付类型", status: 400
    end
  end

  private

    def recharge_klass
      Recharge.where(user_id: current_merchant, store_id: current_store)
    end

    def recharge_params
      params.require(:recharge).permit(:amount)
    end
end
