class UsersController < ApplicationController
  skip_before_filter :authenticate!, except: :show
  before_filter :find_user, only: [ :new, :edit, :update ]

  def update
    if @user.update_attributes(user_params)
      redirect_to session[:original_url] || root_path
    else
      render :edit
    end
  end

  private

    def find_user
      @user = current_user
    end

    def user_params
      params.require(:user).permit(:mobile, :nickname, :gender, :address, :mobile_confirmed)
    end
end
