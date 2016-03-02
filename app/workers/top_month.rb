class TopMonthlyUserSendGift
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { daily().hour_of_day(17).minute_of_hour(20) }
	def perform()
		MonthlyTopBctReceivedHeart.destroy_all
		MonthlyTopBctReceivedHeart.connection.execute("ALTER TABLE monthly_top_bct_received_hearts AUTO_INCREMENT = 1")
		users = User.where(is_broadcaster: 1).order('no_heart DESC').limit(10)
		users.each do |user|
			MonthlyTopBctReceivedHeart.create(:broadcaster_id => user.broadcaster.id, :quantity => user.no_heart)
		end
		
		MonthlyTopUserSendGift.destroy_all
		MonthlyTopUserSendGift.connection.execute("ALTER TABLE monthly_top_user_send_gifts AUTO_INCREMENT = 1")
		monthly_user_logs = UserLog.select('user_id, sum(money) as money').group(:user_id).order('money DESC').limit(10)
		monthly_user_logs.each do |monthly_user_log|
			MonthlyTopUserSendGift.create(:user_id => monthly_user_log.user_id, :money => 1, :money => monthly_user_log.money)
		end
	end
end