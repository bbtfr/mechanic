class Merchants::ApplicationController < ActionController::Base
  layout "merchants"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_merchant_session, :current_merchant
  before_filter :authenticate!

  private

    def current_merchant_session
      return @current_merchant_session if defined?(@current_merchant_session)
      @current_merchant_session = MerchantSession.find
    end

    def current_merchant
      return @current_merchant if defined?(@current_merchant)
      @current_merchant = current_merchant_session && current_merchant_session.merchant
    end

    def authenticate!
      if !current_merchant_session || !current_merchant
        session[:original_url] = request.original_url
        redirect_to new_merchants_merchant_session_path
      else
        session[:original_url] = nil if session[:original_url]
      end
    end
end
