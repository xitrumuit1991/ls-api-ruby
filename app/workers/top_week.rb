class TopWeek
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { weekly.day(:monday).hour_of_day(2).minute_of_hour(0) }
	def perform()
		WeeklyTopBctReceivedHeart.destroy_all
		WeeklyTopBctReceivedHeart.connection.execute("ALTER TABLE top_bct_received_hearts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).group(:room_id).order('quantity DESC').limit(5)
		hearts.each do |heart|
			WeeklyTopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end

		WeeklyTopUserSendGift.destroy_all
		WeeklyTopUserSendGift.connection.execute("ALTER TABLE weekly_top_user_send_gifts AUTO_INCREMENT = 1")
		weekly_user_logs = UserLog.select('user_id, sum(money) as money').where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).group(:user_id).order('money DESC').limit(5)
		weekly_user_logs.each do |weekly_user_log|
			WeeklyTopUserSendGift.create(:user_id => weekly_user_log.user_id, :money => weekly_user_log.money)
		end
	end
end