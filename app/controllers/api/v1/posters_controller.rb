class Api::V1::PostersController < Api::V1::ApplicationController
  #include Api::V1::Authorize
  def getSliders
  	@sliders = Slide.all().order('weight asc').limit(3)
  	@sliders = Rails.cache.fetch('home_slider')
  end

  def getPosters
  	@posters = Poster.all().order('weight asc').limit(4)
  	@posters = Rails.cache.fetch('home_poster')
  end
end