class TopMonth
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { monthly }
	def perform()
		MonthlyTopBctReceivedHeart.destroy_all
		MonthlyTopBctReceivedHeart.connection.execute("ALTER TABLE monthly_top_bct_received_hearts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').where(created_at: DateTime.now.beginning_of_month..DateTime.now).group(:room_id).order('quantity DESC').limit(10)
		hearts.each do |heart|
			MonthlyTopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end
		
		MonthlyTopUserSendGift.destroy_all
		MonthlyTopUserSendGift.connection.execute("ALTER TABLE monthly_top_user_send_gifts AUTO_INCREMENT = 1")
		monthly_user_logs = UserLog.select('user_id, sum(money) as money').where(created_at: DateTime.now.beginning_of_month..DateTime.now).group(:user_id).order('money DESC').limit(10)
		monthly_user_logs.each do |monthly_user_log|
			MonthlyTopUserSendGift.create(:user_id => monthly_user_log.user_id, :money => monthly_user_log.money)
		end
	end
end