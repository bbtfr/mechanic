class Admin::Setting::SeriesController < Admin::ApplicationController
  def index
    @series = Series.all
  end
end
