class Api::V1::AppConfigsController < Api::V1::ApplicationController
  #include Api::V1::Authorize
  def versionCheck
    @min_version = AppConfig.find_by_key("app_#{params[:os]}_#{params[:app]}_min_version")
    @max_version = AppConfig.find_by_key("app_#{params[:os]}_#{params[:app]}_max_version")
    @force_update = Gem::Version.new("#{params[:version]}") < Gem::Version.new("#{@min_version.value}") ? true : false
    # logger.info("---------@min_version: ") 
	# logger.info("---------@min_version: ") 
	# logger.info(@min_version.to_json) 
	# logger.info("---------@max_version: ") 
	# logger.info("---------@max_version: ") 
	# logger.info(@max_version.to_json) 
	# logger.info("---------@force_update: ") 
	# logger.info("---------@force_update: ") 
	# logger.info(@force_update) 
  end
end