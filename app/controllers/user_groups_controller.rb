class UserGroupsController < ApplicationController

  def new
    @user_group = user_group_klass.new
  end

  private

    def user_group_klass
      UserGroup.where(user_id: current_user)
    end

    def user_group_params
      params.require(:user_group).permit(:nickname, :description)
    end
end
