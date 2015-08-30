class UserGroupsController < ApplicationController

  def new
    @user_group = user_group_klass.first || user_group_klass.new
    flash[:notice] = "堂主申请正在审核中..." if @user_group.persisted?
  end

  def create
    @user_group = user_group_klass.new(user_group_params)
    if @user_group.save
      redirect_to settings_user_path
    else
      render :new
    end
  end

  def update
    @user_group = user_group_klass.first
    if @user_group.update_attributes(user_group_params)
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
