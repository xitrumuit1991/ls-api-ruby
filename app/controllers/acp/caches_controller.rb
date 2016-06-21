class Acp::CachesController < Acp::ApplicationController
  # authorize_resource :class => false
  
  def index
  end

  def clearCacheClider
  	Rails.cache.delete("home_slider")
		Rails.cache.fetch("home_slider") do
			Slide.all().order('weight asc').limit(3)
		end
  	redirect_to({ action: 'index' }, notice: 'Clear successfully.')
  end

  def clearCachePoster
  	Rails.cache.delete("home_poster")
		Rails.cache.fetch("home_poster") do
			Poster.all().order('weight asc').limit(4)
		end
  	redirect_to({ action: 'index' }, notice: 'Clear successfully.')
  end

end