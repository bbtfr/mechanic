class Admin::MechanicsController < Admin::ApplicationController
  def index
    @mechanics = User.where(is_mechanic: true).all
  end

  def show
    @mechanic = User.find(params[:id])
  end
end
