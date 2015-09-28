class Merchants::MerchantSessionsController < Merchants::ApplicationController
  skip_before_filter :authenticate!, except: [ :destroy ]

  def new
    @merchant_session = MerchantSession.new
  end

  def create
    @merchant_session = MerchantSession.new(merchant_session_params)
    if @merchant_session.save
      redirect_to session[:original_url] || merchants_root_path
    else
      merchant = @merchant_session.attempted_record
      if merchant && !merchant.confirmed?
        session[:mobile] = merchant.mobile
        link_url = verification_code_merchants_merchant_path
        @merchant_session.errors.add :base, "点击这里<a href=\"#{link_url}\">重新发送验证码</a>".html_safe
      end

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
