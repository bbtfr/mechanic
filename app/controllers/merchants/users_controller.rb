class Merchants::UsersController < Merchants::ApplicationController
  before_filter :authenticate!, except: [ :new, :create ]
  before_filter :find_user, only: [ :edit, :update ]

  def new
    @user = User.new
    @user.build_merchant
  end

  def create
    @user = User.new(user_params)
    @user.build_merchant(merchant_params)
    if @user.save
      redirect_to session[:original_url] || root_path
    else
      render :new
    end
  end

  def update
    @user.assign_attributes(user_params)
    @user.build_merchant unless @user.merchant
    @user.merchant.assign_attributes(merchant_params)
    if @user.save
      redirect_to user_path
    else
      render :edit
    end
  end

  private

    def find_user
      @user = current_user
    end

    def user_params
      params.require(:user).permit(:mobile, :nickname, :gender, :address, :mobile_confirmed, :avatar,
        :mechanic?)
    end

    def merchant_params
      params.require(:user).permit(:province_id, :city_id, :district_id, :description, skill_ids: [])
    end
end
