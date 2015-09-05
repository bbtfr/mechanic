class Admin::UsersController < Admin::ApplicationController
  before_filter :find_user, except: [ :index ]

  def index
    @users = User.where(is_mechanic: false)
  end

  private

    def find_user
      @user = User.find(params[:id])
    end
end
