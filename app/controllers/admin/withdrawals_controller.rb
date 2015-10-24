class Admin::WithdrawalsController < Admin::ApplicationController
  before_filter :find_withdrawal, except: [ :index, :settings, :update_settings ]

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

  def update_settings
    setting_params.each do |key, value|
      ::Setting[key] = value
    end
    redirect_to settings_admin_withdrawals_path
  end

  private

    def find_withdrawal
      @withdrawal = Withdrawal.find(params[:id])
    end

    def setting_params
      params.require(:setting).permit(:commission_percent, :mobile_commission_percent,
        :client_commission_percent, :mechanic_commission_percent)
    end
end
