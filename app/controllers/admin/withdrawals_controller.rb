class Admin::WithdrawalsController < Admin::ApplicationController
  before_filter :find_withdrawal, except: [ :index ]

  def index
    @withdrawals = Withdrawal.all
  end

  def confirm
    response = Weixin.withdrawal @withdrawal
    if response.success?
      @withdrawal.pay!
    else
      flash[:error] = response["return_msg"]
    end
    redirect_to request.referer
  end

  private

    def find_withdrawal
      @withdrawal = Withdrawal.find(params[:id])
    end
end
