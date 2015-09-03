class Admin::UsersController < Admin::ApplicationController
  def index
    @users = User.where(is_mechanic: false)
  end

  def show
    @user = User.find(params[:id])
  end
end
