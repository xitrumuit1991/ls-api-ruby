class TopYear
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	recurrence { weekly.day(:monday).hour_of_day(2).minute_of_hour(0) }
	def perform()
		TopBctReceivedHeart.destroy_all
		TopBctReceivedHeart.connection.execute("ALTER TABLE top_user_send_gifts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').group(:room_id).order('quantity DESC').limit(5)
		hearts.each do |heart|
			TopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end
	end
end