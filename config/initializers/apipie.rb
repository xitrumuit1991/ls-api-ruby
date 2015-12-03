Apipie.configure do |config|
  config.app_name                = "Livestar API"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/api/doc"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/*/*.rb"
  config.app_info = "API for Livestar"
  config.copyright = "&copy; 2015 Livestar"
  config.authenticate = Proc.new do
     authenticate_or_request_with_http_basic do |username, password|
       username == "doc" && password == "doc"
    end
  end
end