class Merchants::MechanicsController < Merchants::ApplicationController
  def follow
    current_merchant.store.follow!(params[:id])
    redirect_to request.referer
  end

  def unfollow
    current_merchant.store.unfollow!(params[:id])
    redirect_to request.referer
  end

  def reviews
    @mechanic = Mechanic.find(params[:id])
    @reviews = @mechanic.orders
  end
end
