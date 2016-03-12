class TopBctReceivedHearts
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { weekly.day(:monday).hour_of_day(2).minute_of_hour(0) }
	def perform()
		TopBctReceivedHeart.destroy_all
		TopBctReceivedHeart.connection.execute("ALTER TABLE top_bct_received_hearts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').where(created_at: DateTime.now.beginning_of_week..DateTime.now).group(:room_id).order('quantity DESC').limit(10)
		hearts.each do |heart|
			TopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end

		WeeklyTopUserSendGift.destroy_all
		WeeklyTopUserSendGift.connection.execute("ALTER TABLE weekly_top_user_send_gifts AUTO_INCREMENT = 1")
		weekly_user_logs = UserLog.select('user_id, sum(money) as money').where(created_at: DateTime.now.beginning_of_week..DateTime.now).group(:user_id).order('money DESC').limit(10)
		weekly_user_logs.each do |weekly_user_log|
			WeeklyTopUserSendGift.create(:user_id => weekly_user_log.user_id, :money => 1, :money => weekly_user_log.money)
		end
	end
end