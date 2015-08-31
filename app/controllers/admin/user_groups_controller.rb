class Admin::UserGroupsController < Admin::ApplicationController
  def index
    @user_groups = UserGroup.unconfirmeds
  end

  def confirmed
    @confirmed = true
    @user_groups = UserGroup.confirmeds
    render :index
  end

  def confirm
    @user_group = UserGroup.find(params[:id])
    @user_group.confirm!
    redirect_to request.referer
  end
end
