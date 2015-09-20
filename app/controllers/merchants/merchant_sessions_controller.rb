class Merchants::MerchantSessionsController < Merchants::ApplicationController
  skip_before_filter :authenticate!

  def new
    @merchant_session = MerchantSession.new
  end

  def create
    @merchant_session = MerchantSession.new(merchant_session_params)
    if @merchant_session.save
      redirect_to session[:original_url] || merchants_root_path
    else
      render :new
    end
  end

  def destroy
    current_merchant_session.destroy
    redirect_to new_merchants_merchant_session_path
  end

  private

    def merchant_session_params
      params.require(:merchant_session).permit(:mobile, :password)
    end
end
