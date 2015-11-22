class Admin::MechanicsController < Admin::ApplicationController
  before_filter :find_mechanic, except: [ :index ]

  def index
    @mechanics = User.mechanics
  end

  def clientize
    @mechanic.client!
    if @mechanic.save
      flash[:error] = "帐号信息不完整，无法转换"
      redirect_to request.referer
    else
      redirect_to admin_user_path(@mechanic)
    end
  end

  private

    def find_mechanic
      @mechanic = User.find(params[:id])
    end
end
