class Merchants::Hosting::OrdersController < Merchants::OrdersController
  skip_before_filter :redirect_pending
  before_filter :redirect_user

  def index
    @state = if %w(unassigneds assigneds workings finisheds).include? params[:state]
        params[:state].to_sym
      else
        :unassigneds
      end
    @orders = order_klass.send(@state)
  end

  def update_procedure_price
    if @order.update_attributes(procedure_price_order_params)
      redirect_to current_order_path
    else
      render :procedure_price
    end
  end

  private

    def current_order_path
      merchants_hosting_order_path(@order)
    end

    def order_klass
      Order.hostings
    end

    def find_order
      @order = order_klass.find(params[:id])
    end

    def redirect_user
      unless current_store.host?
        flash[:error] = "无法访问此页面！"
        redirect_to merchants_root_path
      end
    end

    def procedure_price_order_params
      params.require(:order).permit(:procedure_price)
    end

end
