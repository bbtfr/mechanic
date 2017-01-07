class Admin::MechanicsController < Admin::ApplicationController
  before_action :find_mechanic, except: [ :index, :new, :create, :import, :create_import ]

  def index
    @state = if %w(all hidden).include? params[:state]
        params[:state].to_sym
      else
        :all
      end
    @mechanics = User.mechanics.send(@state)
  end

  def clientize
    @mechanic.client!
    if @mechanic.save
      redirect_to admin_user_path(@mechanic)
    else
      flash[:error] = "帐号信息不完整，无法转换"
      redirect_to_referer!
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

  def hide
    @mechanic.hide!
    redirect_to_referer!
  end

  def unhide
    @mechanic.unhide!
    redirect_to_referer!
  end

  def create_import
    file = params[:import][:mechanics]
    @importer = Mechanic::Importer.new(file)
  end

  private

    def find_mechanic
      @mechanic = User.find(params[:id])
    end

    def mechanic_params
      params.require(:user).permit(:mobile, :nickname, :gender, :address, :weixin_openid,
        mechanic_attributes: [ :unique_id, :province_cd, :city_cd, :district_cd, :description, skill_cds: [] ])
    end

end
