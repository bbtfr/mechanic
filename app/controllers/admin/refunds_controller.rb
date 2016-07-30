class Admin::RefundsController < Admin::ApplicationController
  before_action :find_order, except: [ :index ]

  def index
    @orders = Order.refundings
  end

  def confirm
    if @order.refunding?
      if @order.pay_type_alipay?
        response = Ali.refund @order
        redirect_to response
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
