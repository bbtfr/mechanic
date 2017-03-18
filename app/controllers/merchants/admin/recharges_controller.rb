class Merchants::Admin::RechargesController < Merchants::Admin::ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate!, :redirect_user, only: [ :notify ]
  before_action :find_recharge, except: [ :index, :new, :create, :notify ]

  def index
    redirect_to new_merchants_admin_recharge_path
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
        redirect_to new_merchants_admin_recharge_path
      end
    else
      render :new
    end
  end

  def result
    case params[:format]
    when "js"
      return
    when "alipay", "weixin"
      notify_params = params.except(*request.path_parameters.keys)
      if Alipay::Notify.verify?(notify_params)
        @recharge.pay! :alipay, notify_params[:trade_no]
      end

      if @recharge.paid?
        flash[:success] = "成功支付订单！"
        redirect_to merchants_root_path
      else
        flash.now[:notice] = "正在查询订单支付结果..."
      end
    else
      flash[:error] = "未知支付类型"
      redirect! :payment, current_order_path
    end
  end

  def notify
    case params[:format]
    when "alipay"
      notify_params = params.except(*request.path_parameters.keys)
      if Alipay::Notify.verify?(notify_params)
        case notify_params[:notify_type]
        when "trade_status_sync"
          Recharge.find(params[:id]).pay! :alipay, notify_params[:trade_no]
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
        Recharge.find(params[:id]).pay! :weixin, notify_params[:transaction_id]
        render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
      else
        render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
      end
    else
      render text: "未知支付类型", status: 400
    end
  end

  private

    def find_recharge
      @recharge = recharge_klass.find(params[:id])
    end

    def recharge_klass
      Recharge.where(merchant_id: current_merchant, store_id: current_store)
    end

    def recharge_params
      params.require(:recharge).permit(:amount)
    end
end
