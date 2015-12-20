class Merchants::MechanicsController < Merchants::ApplicationController
  before_filter :find_mechanic, only: [:show, :reviews, :remark, :update_remark, :skill]

  def follow
    current_merchant.store.follow!(params[:id])
    redirect_to request.referer
  end

  def unfollow
    current_merchant.store.unfollow!(params[:id])
    redirect_to request.referer
  end

  def reviews
    @reviews = @mechanic.orders
  end

  def update_remark
    @fellowship = Fellowship.where(mechanic_id: @mechanic.id, user_id: current_merchant.user_id).first

    if @fellowship && @fellowship.update_attributes(fellowship_params)
      flash[:notice] = "成功更新备注！"
      redirect_to merchants_mechanic_path(@mechanic)
    else
      render :remark
    end
  end

  private
    def find_mechanic
      @mechanic = Mechanic.find(params[:id])
    end

    def fellowship_params
      params.require(:fellowship).permit(:remark)
    end
end
