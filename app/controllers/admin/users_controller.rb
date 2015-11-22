class Admin::UsersController < Admin::ApplicationController
  before_filter :find_user, except: [ :index ]

  def index
    @users = User.clients
  end

  def mechanicize
    @user.mechanic!
    @user.save
    redirect_to request.referer
  end

  private

    def find_user
      @user = User.find(params[:id])
    end
end
