class WithdrawalsController < ApplicationController
  def new
    @withdrawal = withdrawal_klass.new
  end

  def create
    @withdrawal = withdrawal_klass.new(withdrawal_params)
    if @withdrawal.save
      redirect_to user_path
    else
      render :new
    end
  end

  private

    def withdrawal_klass
      Withdrawal.where(user_id: current_user)
    end

    def withdrawal_params
      params.require(:withdrawal).permit(:amount)
    end
end
