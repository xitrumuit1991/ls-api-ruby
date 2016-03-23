class TopYear
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { yearly }
	def perform()
		TopUserSendGift.destroy_all
		TopUserSendGift.connection.execute("ALTER TABLE top_user_send_gifts AUTO_INCREMENT = 1")
		all_user_logs = UserLog.select('user_id, sum(money) as money').group(:user_id).order('money DESC').limit(10)
		all_user_logs.each do |all_user_log|
			TopUserSendGift.create(:user_id => all_user_log.user_id, :money => all_user_log.money)
		end
	end
end