class Admin::OrdersController < Admin::ApplicationController
  before_filter :find_order, except: [ :index ]

  def index
    @orders = Order.all
  end

  private

    def find_order
      @order = Order.find(params[:id])
    end
end
