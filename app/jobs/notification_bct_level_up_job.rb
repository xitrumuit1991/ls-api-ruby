class NotificationBctLevelUpJob < ActiveJob::Base
	queue_as :default

	def perform(room_id, new_value)
		emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
		emitter.of("/room").in(room_id).emit("broadcaster levelup", {new_level: new_value})
	end
end
