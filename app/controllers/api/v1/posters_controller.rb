class Api::V1::PostersController < Api::V1::ApplicationController
  #include Api::V1::Authorize
  def deleteCacheAll
  	Rails.cache.delete("home_poster")
  	Rails.cache.delete("home_slider")
  	sliders = Rails.cache.fetch('home_slider')
  	# logger.info("---------sliders:#{sliders.to_json}")
  	posters = Rails.cache.fetch('home_poster')
  	# logger.info("---------posters:#{posters.to_json}")
  	render json: {success: 1, message: 'clear cache ok'}, status: 200
  	return
	end
  def getSliders
  	sliders = Rails.cache.fetch('home_slider')
    if sliders.present?
      # logger.info("---------getSliders has cache")
      # logger.info("---------getSliders:")
      # logger.info("---------getSliders:")
      @sliders = sliders
      logger.info(@sliders.to_json) 
    else
      # logger.info("---------create cache getSliders:")
      Rails.cache.delete("home_slider")
      Rails.cache.fetch("home_slider") do
        Slide.all().order('weight asc').limit(3)
      end
      @sliders = Rails.cache.fetch('home_slider')
    end
  end

  def getPosters
    posters = Rails.cache.fetch('home_poster')
    if posters.present?
      # logger.info("---------getPosters has cache")
      # logger.info("---------getPosters:")
      # logger.info("---------getPosters:")
      @posters = posters
      logger.info(@posters.to_json) 
    else
      # logger.info("---------create cache getPosters:")
      Rails.cache.delete("home_poster")
      Rails.cache.fetch("home_poster") do
        Poster.all().order('weight asc').limit(4)
      end
      @posters = Rails.cache.fetch('home_poster')
    end
  end
end