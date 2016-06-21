class TopMonth
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { weekly.day(:monday).hour_of_day(2).minute_of_hour(0) }
	def perform()
		MonthlyTopBctReceivedHeart.destroy_all
		MonthlyTopBctReceivedHeart.connection.execute("ALTER TABLE monthly_top_bct_received_hearts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).group(:room_id).order('quantity DESC').limit(5)
		hearts.each do |heart|
			MonthlyTopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end
		Rails.cache.delete("top_broadcaster_revcived_heart_month")
		Rails.cache.fetch("top_broadcaster_revcived_heart_month") do
			MonthlyTopBctReceivedHeart::all
		end
		
		MonthlyTopUserSendGift.destroy_all
		MonthlyTopUserSendGift.connection.execute("ALTER TABLE monthly_top_user_send_gifts AUTO_INCREMENT = 1")
		monthly_user_logs = UserLog.select('user_id, sum(money) as money').where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).group(:user_id).order('money DESC').limit(5)
		monthly_user_logs.each do |monthly_user_log|
			MonthlyTopUserSendGift.create(:user_id => monthly_user_log.user_id, :money => monthly_user_log.money)
		end
		Rails.cache.delete("top_user_send_gift_month")
		Rails.cache.fetch("top_user_send_gift_month") do
			MonthlyTopUserSendGift::all
		end
	end
end