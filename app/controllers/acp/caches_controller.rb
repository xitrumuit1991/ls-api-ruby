class Acp::CachesController < Acp::ApplicationController
  # authorize_resource :class => false
  
  def index
  end

  def clearCacheClider
  	Rails.cache.delete("home_slider")
		Rails.cache.fetch("home_slider") do
			Slide.all().order('weight asc').limit(3)
		end
  	redirect_to({ action: 'index' }, notice: 'Clear Cache Clider successfully.')
  end

  def clearCachePoster
  	Rails.cache.delete("home_poster")
		Rails.cache.fetch("home_poster") do
			Poster.all().order('weight asc').limit(4)
		end
  	redirect_to({ action: 'index' }, notice: 'Clear Cache Poster successfully.')
  end

  def clearCacheHomeFeatured
  	Rails.cache.delete("home_featured")
		Rails.cache.fetch("home_featured") do
			HomeFeatured.order(weight: :asc).limit(6)
		end
  	redirect_to({ action: 'index' }, notice: 'Clear Cache Featured successfully.')
  end

end