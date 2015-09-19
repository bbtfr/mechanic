class UsersController < ApplicationController
  before_filter :validate!, except: [ :new, :create ]
  before_filter :find_user, only: [ :new, :create, :edit, :update ]

  def create
    @user.assign_attributes(user_params)
    @user.build_mechanic(mechanic_params) if @user.mechanic?
    if @user.save
      redirect_to session[:original_url] || root_path
    else
      render :new
    end
  end

  def update
    @user.assign_attributes(user_params)
    @user.build_mechanic unless @user.mechanic
    @user.mechanic.assign_attributes(mechanic_params) if @user.mechanic?
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
        :is_mechanic)
    end

    def mechanic_params
      params.require(:user).permit(:province_id, :city_id, :district_id, :description, skill_ids: [])
    end

    def authenticate!
      if !current_user_session || !current_user || !current_user.mobile_confirmed
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
