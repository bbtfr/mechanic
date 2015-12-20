class Merchants::Admin::OrdersController < Merchants::Admin::ApplicationController
  before_filter :find_order, except: [ :index ]

  def index
    @state = if %w(pendeds paids workings settleds).include? params[:state]
        params[:state].to_sym
      else
        :pendeds
      end
    @orders = order_klass.send(@state)
  end

  private

    def find_order
      @order = order_klass.find(params[:id])
    end

    def order_klass
      Order.where(user_id: current_store)
    end
end
