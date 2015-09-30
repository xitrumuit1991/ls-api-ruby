class NotificationChangeExpJob < ActiveJob::Base
	queue_as :default

	def perform(email, old_value, new_value, percent)
		redis = Redis.new
		socket_id = redis.get("notification:#{email}")
		if socket_id
			emitter = SocketIO::Emitter.new
			emitter.of("/notification").in(socket_id).emit("change exp", { old_value: old_value, new_value: new_value, percent: percent })
		end
	end
end
