class Admin::MechanicsController < Admin::ApplicationController
  def index
    @mechanics = User.where(is_mechanic: true).all
  end
end
