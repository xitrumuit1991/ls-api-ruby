class UserLogJob < ActiveJob::Base
	queue_as :default
	def perform(user, room_id, total)
		userlog = UserLog.new
		userlog.create(user_id: user.id, room_id: room_id, money: total)
		# Rails.logger.info("UserLogJob insert user_log")
		# user.user_logs.create(room_id: room_id, money: total)
		# Rails.logger.info("user.user_logs=#{user.user_logs}")
		# if user.user_logs.present?
		# 	Rails.logger.info("user.user_logs=#{user.user_logs.to_json}")
		# end
	end
end