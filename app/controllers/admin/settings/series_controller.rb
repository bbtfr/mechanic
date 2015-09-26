class Admin::Settings::SeriesController < Admin::ApplicationController
  before_filter :find_series, only: [ :edit, :update, :destroy ]

  def index
    @series = Series.all
  end

  def new
    @series = Series.new
  end

  def create
    @series = Series.new(series_params)
    if @series.save
      redirect_to "/admin/settings/series"
    else
      render :new
    end
  end

  def update
    if @series.update_attributes(series_params)
      redirect_to "/admin/settings/series"
    else
      render :edit
    end
  end

  def destroy
    @series.destroy
    redirect_to "/admin/settings/series"
  end

  private

    def series_params
      params.require(:series).permit(:name, :brand_id)
    end

    def find_series
      @series = Series.find(params[:id])
    end
end
