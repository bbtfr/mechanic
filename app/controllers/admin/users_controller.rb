class Admin::UsersController < Admin::ApplicationController
  before_filter :find_user, except: [ :index ]

  def index
    @users = User.clients
  end

  def mechanicize
    @user.mechanic!
    @user.build_mechanic unless @user.mechanic
    if @user.save
      flash[:error] = "帐号信息不完整，无法转换"
      redirect_to request.referer
    else
      redirect_to admin_mechanic_path(@user)
    end
  end

  private

    def find_user
      @user = User.find(params[:id])
    end
end
