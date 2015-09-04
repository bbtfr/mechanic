class Admin::WithdrawalsController < Admin::ApplicationController
  def index
    @withdrawals = Withdrawal.all
  end

  def show
    @withdrawal = Withdrawal.find(params[:id])
  end

  def confirm
    @withdrawal = Withdrawal.find(params[:id])
    response = Weixin.withdrawal @withdrawal
    if response.success?
      @withdrawal.pay!
    else
      flash[:error] = response["return_msg"]
    end
    redirect_to request.referer
  end
end
