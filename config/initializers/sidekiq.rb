Sidekiq.configure_server do |config|
	url='redis://'+Settings.redis_host.to_s+':'+Settings.redis_port.to_s+'/12'
  config.redis = { url: url }
end

Sidekiq.configure_client do |config|
	url='redis://'+Settings.redis_host.to_s+':'+Settings.redis_port.to_s+'/12'
  config.redis = { url: url }
end
