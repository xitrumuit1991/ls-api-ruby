class NotificationChangeBctExpJob < ActiveJob::Base
	queue_as :default

	def perform(room_id, old_value, new_value, percent)
		$emitter.of("/room").in(room_id).emit("change broadcaster exp", { old_value: old_value, new_value: new_value, percent: percent })
	end
end
