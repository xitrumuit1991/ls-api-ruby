class NotificationBctLevelUpJob < ActiveJob::Base
	queue_as :default

	def perform(room_id, new_value)
		$emitter.of("/room").in(room_id).emit("broadcaster levelup", {new_level: new_value})
	end
end
