class Merchants::Admin::ApplicationController <  Merchants::ApplicationController
  before_action :redirect_user

  private

    def redirect_user
      if current_merchant && current_merchant.dispatcher?
        flash[:error] = "派单员无法访问此页面！"
        redirect_to merchants_root_path
      end
    end

end
