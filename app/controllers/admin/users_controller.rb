class Admin::UsersController < Admin::ApplicationController
  before_action :redirect_user, only: [ :balance, :update_balance ]
  before_action :find_user, except: [ :index ]

  def index
    @users = User.clients
  end

  def mechanicize
    @user.mechanic!
    @user.build_mechanic unless @user.mechanic
    if @user.save
      redirect_to admin_mechanic_path(@user)
    else
      flash[:error] = "帐号信息不完整，无法转换"
      redirect_to_referer!
    end
  end

  def balance
    set_redirect_referer :balance
  end

  def update_balance
    amount = params[:user][:balance_update_amount].to_f
    description = params[:user][:balance_update_description]
    if @user.update_balance! amount, description
      flash[:success] = "成功更新账户余额！"
      redirect! :balance, admin_user_path(@user)
    else
      render :balance
    end
  end

  private

    def find_user
      @user = User.find(params[:id])
    end
end
