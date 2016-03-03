class TopBctReceivedHearts
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { daily().hour_of_day(17).minute_of_hour(20) }
	def perform()
		TopBctReceivedHeart.destroy_all
		TopBctReceivedHeart.connection.execute("ALTER TABLE top_bct_received_hearts AUTO_INCREMENT = 1")
		users = User.where(is_broadcaster: 1).order('no_heart DESC').limit(10)
		users.each do |user|
			TopBctReceivedHeart.create(:broadcaster_id => user.broadcaster.id, :quantity => user.no_heart)
		end

		WeeklyTopUserSendGift.destroy_all
		WeeklyTopUserSendGift.connection.execute("ALTER TABLE weekly_top_user_send_gifts AUTO_INCREMENT = 1")
		weekly_user_logs = UserLog.select('user_id, sum(money) as money').where(created_at: DateTime.now.beginning_of_week..DateTime.now).group(:user_id).order('money DESC').limit(10)
		weekly_user_logs.each do |weekly_user_log|
			WeeklyTopUserSendGift.create(:user_id => weekly_user_log.user_id, :money => 1, :money => weekly_user_log.money)
		end
	end
end