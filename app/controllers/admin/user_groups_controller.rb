class Admin::UserGroupsController < Admin::ApplicationController
  before_filter :find_user_group, except: [ :index, :confirmed ]

  def index
    @user_groups = UserGroup.unconfirmeds
  end

  def confirmed
    @confirmed = true
    @user_groups = UserGroup.confirmeds
    render :index
  end

  def confirm
    @user_group.confirm!
    redirect_to request.referer
  end

  def destroy
    @user_group.destroy
    redirect_to request.referer
  end

  private

    def find_user_group
      @user_group = UserGroup.find(params[:id])
    end
end
