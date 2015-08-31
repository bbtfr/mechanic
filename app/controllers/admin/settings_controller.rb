class Admin::SettingsController < Admin::ApplicationController
  def show
    @brands = Brand.all
  end

  def series
    @series = Series.all
  end

end
