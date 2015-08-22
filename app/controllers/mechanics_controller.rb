class MechanicsController < ApplicationController
  def index
    @mechanics = mechanic_klass.all
  end
  private

    def find_mechanic
      @order = order_klass.find(params[:id])
    end

    def mechanic_klass
      Mechanic
    end

    def mechanic_params
      params.require(:order).permit(:user_id, :mechanic_id, :address, :appointment,
        :skill_id, :brand_id, :series_id, :quoted_price, :remark)
    end
end
