class Api::V1::PostersController < Api::V1::ApplicationController
  #include Api::V1::Authorize
  def getSliders
  	@sliders = Rails.cache.fetch('home_slider')
  end

  def getPosters
  	@posters = Rails.cache.fetch('home_poster')
  end
end