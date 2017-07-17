class UserLogJob < ActiveJob::Base
	queue_as :default
	def perform(user, room_id, total)
		user.user_logs.create(room_id: room_id, money: total)
	end
end