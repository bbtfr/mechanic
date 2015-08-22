class UserGroupsController < ApplicationController

  def new
    @user_group = user_group_klass.new
  end

  def create
    @user_group = user_group_klass.new(user_group_params)
    if @user_group.save
      redirect_to settings_user_path
    else
      render :new
    end
  end

  private

    def user_group_klass
      UserGroup.where(user_id: current_user)
    end

    def user_group_params
      params.require(:user_group).permit(:nickname, :description)
    end
end
