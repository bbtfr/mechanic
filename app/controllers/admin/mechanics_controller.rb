class Admin::MechanicsController < Admin::ApplicationController
  before_filter :find_mechanic, except: [ :index ]

  def index
    @mechanics = User.mechanics
  end

  private

    def find_mechanic
      @mechanic = User.find(params[:id])
    end
end
