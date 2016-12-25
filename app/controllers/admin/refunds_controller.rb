class Admin::RefundsController < Admin::ApplicationController
  before_action :redirect_user
  before_action :find_order, except: [ :index ]

  def index
    @orders = Order.refundings
  end

  def confirm
    if @order.refunding?
      case @order.pay_type
      when :alipay
        response = Ali.refund @order
        redirect_to response
      when :weixin
        response = Weixin.refund @order
        if response.success?
          flash[:notice] = "退款申请已提交，支付款将在3个工作日内退回您的账户..."
          @order.refund!
        else
          flash[:error] = "微信支付：#{response["err_code_des"]}"
        end
        redirect_to request.referer
      when :balance
        @order.refund!
        redirect_to request.referer
      else
        flash[:error] = "未知支付类型"
        redirect_to request.referer
      end
    else
      flash[:error] = "订单状态错误！"
      redirect_to request.referer
    end
  end

  private

    def find_order
      @order = Order.find(params[:id])
    end
end
