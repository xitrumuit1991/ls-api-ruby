class NotificationLevelUpJob < ActiveJob::Base
  queue_as :default

  def perform(email, new_value)
		socket_id = $redis.get("notification:#{email}")
		if socket_id
			$emitter.of("/notification").in(socket_id).emit("levelup", {new_level: new_value})
		end
	end
end
