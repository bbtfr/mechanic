class MechanicsController < ApplicationController
  def follow
    current_user.follow!(params[:id])
    redirect_to_referer!
  end

  def unfollow
    current_user.unfollow!(params[:id])
    redirect_to_referer!
  end

  def reviews
    @mechanic = Mechanic.find(params[:id])
    @reviews = @mechanic.orders
  end
end
