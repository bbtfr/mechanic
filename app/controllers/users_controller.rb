class UsersController < ApplicationController
  before_filter :validate!, except: [ :new, :create ]
  before_filter :find_user, only: [ :new, :create, :edit, :update ]

  def new
    @user.build_mechanic unless @user.mechanic
  end

  def create
    if @user.update_attributes(user_params)
      redirect_to session[:original_url] || root_path
    else
      render :new
    end
  end

  def update
    if @user.update_attributes(user_params)
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
      params.require(:user).permit(:mobile, :nickname, :gender, :address, :avatar,
        mechanic_attributes: [:_create, :id, :province_cd, :city_cd, :district_cd, :description,
        {skill_cds: []}])
    end

    def authenticate!
      if !current_user_session || !current_user
        session[:original_url] = request.original_url
        redirect_to new_user_session_path
      else
        session[:original_url] = nil if session[:original_url]
      end
    end

    def validate!
      if current_user.invalid?
        session[:original_url] = request.original_url
        redirect_to new_user_path
      else
        session[:original_url] = nil if session[:original_url]
      end
    end
end
