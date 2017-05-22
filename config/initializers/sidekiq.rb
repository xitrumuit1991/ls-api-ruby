Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://db.livestar.vn:6379/12' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://db.livestar.vn:6379/12' }
end
