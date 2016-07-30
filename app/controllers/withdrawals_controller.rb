class WithdrawalsController < ApplicationController
  before_action :find_withdrawals_by_state

  helper_method :withdrawal_klass

  def new
    @withdrawal = withdrawal_klass.new
  end

  def create
    @withdrawal = withdrawal_klass.new(withdrawal_params)
    if @withdrawal.save
      flash[:success] = "提现申请已提交，等待管理员审核..."
      redirect_to user_path
    else
      render :new
    end
  end

  private

    def find_withdrawals_by_state
      @state = if %w(pendings paids canceleds).include? params[:state]
          params[:state].to_sym
        else
          :pendings
        end
      @withdrawals = withdrawal_klass.send(@state)
    end

    def withdrawal_klass
      Withdrawal.where(user_id: current_user)
    end

    def withdrawal_params
      params.require(:withdrawal).permit(:amount)
    end
end
