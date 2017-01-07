class Admin::UserGroupsController < Admin::ApplicationController
  before_action :find_user_group, except: [ :index, :confirmed ]

  def index
    @user_groups = UserGroup.unconfirmeds
  end

  def confirmed
    @user_groups = UserGroup.confirmeds
    render :index
  end

  def confirm
    @user_group.confirm!
    redirect_to_referer!
  end

  def destroy
    @user_group.destroy
    redirect_to_referer!
  end

  private

    def find_user_group
      @user_group = UserGroup.find(params[:id])
    end
end
