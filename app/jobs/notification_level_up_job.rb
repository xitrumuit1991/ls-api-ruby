class NotificationLevelUpJob < ActiveJob::Base
  queue_as :default

  def perform(email, new_value)
		redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
		socket_id = redis.get("notification:#{email}")
		if socket_id
			emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
			emitter.of("/notification").in(socket_id).emit("levelup", {new_level: new_value})
		end
	end
end
