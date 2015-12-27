class Merchants::ApplicationController < ActionController::Base
  include RedirectionHelper

  layout "merchants"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_merchant_session, :current_merchant, :current_store
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

    def current_store
      return @current_store if defined?(@current_store)
      @current_store = current_merchant && current_merchant.store
    end

    def authenticate!
      if !current_merchant_session || !current_merchant
        set_redirect_original_url :authenticate
        redirect_to new_merchants_merchant_session_path
      else
        clear_redirect :authenticate
      end
    end
end
