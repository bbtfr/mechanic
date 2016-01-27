class Admin::MechanicsController < Admin::ApplicationController
  before_filter :find_mechanic, except: [ :index, :new, :create ]

  def index
    @mechanics = User.mechanics
  end

  def clientize
    @mechanic.client!
    if @mechanic.save
      redirect_to admin_user_path(@mechanic)
    else
      flash[:error] = "帐号信息不完整，无法转换"
      redirect_to request.referer
    end
  end

  def new
    @mechanic = User.new
    @mechanic.build_mechanic
  end

  def create
    @mechanic = User.new(mechanic_params)
    @mechanic.mechanic!
    if @mechanic.save
      redirect_to admin_mechanics_path
    else
      render :new
    end
  end

  def update
    if @mechanic.update_attributes(mechanic_params)
      redirect_to admin_mechanics_path
    else
      render :new
    end
  end

  private

    def find_mechanic
      @mechanic = User.find(params[:id])
    end

    def mechanic_params
      params.require(:user).permit(:mobile, :nickname, :gender, :address,
        mechanic_attributes: [ :province_cd, :city_cd, :district_cd, :description, skill_cds: [] ])
    end

end
