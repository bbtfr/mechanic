class Admin::Settings::BrandsController < Admin::ApplicationController
  before_filter :find_brand, only: [ :edit, :update, :destroy ]

  def index
    @brands = Brand.all
  end

  def new
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      redirect_to admin_settings_brands_path
    else
      render :new
    end
  end

  def update
    if @brand.update_attributes(brand_params)
      redirect_to admin_settings_brands_path
    else
      render :edit
    end
  end

  def destroy
    @brand.destroy
    redirect_to admin_settings_brands_path
  end

  private

    def brand_params
      params.require(:brand).permit(:name)
    end

    def find_brand
      @brand = Brand.find(params[:id])
    end
end
