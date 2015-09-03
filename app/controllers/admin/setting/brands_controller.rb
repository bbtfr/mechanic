class Admin::Setting::BrandsController < Admin::ApplicationController
  def index
    @brands = Brand.all
  end
end
