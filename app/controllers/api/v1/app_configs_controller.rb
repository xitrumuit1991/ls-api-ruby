class Api::V1::AppConfigsController < Api::V1::ApplicationController
  #include Api::V1::Authorize
  def versionCheck
    @min_version = AppConfig.find_by_key("app_#{params[:os]}_#{params[:app]}_min_version")
    @max_version = AppConfig.find_by_key("app_#{params[:os]}_#{params[:app]}_max_version")
    @force_update = AppConfig.find_by_key("app_#{params[:os]}_#{params[:app]}_force_update")
    puts '========================'
    puts "app_#{params[:os]}_#{params[:app]}_min_version"
    puts "app_#{params[:os]}_#{params[:app]}_max_version"
    puts "app_#{params[:os]}_#{params[:app]}_force_update"
    puts params[:os]
    puts @min_version.value
    puts @max_version.value
    puts @force_update.value
    puts '========================'
  end
end