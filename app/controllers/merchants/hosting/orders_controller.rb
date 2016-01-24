class Merchants::Hosting::OrdersController < Merchants::OrdersController
  before_filter :redirect_user

  def index
    @state = if %w(paids workings finisheds).include? params[:state]
        params[:state].to_sym
      else
        :paids
      end
    @orders = order_klass.send(@state)
  end

  def update_pick
    if @order.update_attributes(order_params)
      redirect_to current_show_path
    else
      render :pick
    end
  end

  private

    def current_show_path
      merchants_hosting_order_path(@order)
    end

    def order_klass
      Order.where(hosting: true)
    end

    def find_order
      @order = admin_order_klass.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:mechanic_id)
    end

    def redirect_user
      unless current_store.host
        flash[:error] = "无法访问此页面！"
        redirect_to merchants_root_path
      end
    end

end
