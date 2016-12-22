class Acp::CachesController < Acp::ApplicationController
	authorize_resource :class => false
	include Api::V1::CacheHelper
	# authorize_resource :class => false

	def index
	end

	def clearCacheClider
		Rails.cache.delete("home_slider")
		Rails.cache.fetch("home_slider") do
			Slide.all().order('weight asc').limit(3)
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Clider successfully.')
	end

	def clearCachePoster
		Rails.cache.delete("home_poster")
		Rails.cache.fetch("home_poster") do
			Poster.all().order('weight asc').limit(4)
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Poster successfully.')
	end

	def clearCacheHomeFeatured
		Rails.cache.delete("home_featured")
		Rails.cache.fetch("home_featured") do
			HomeFeatured.order(weight: :asc).limit(6)
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Home Featured successfully.')
	end

	def deactiveUserBlacklist
		User.all.where(actived: true, deleted: 0).each do |user|
			if Rails.cache.fetch("email_black_list").include?(user.email.split("@")[1])
				EmailDomainBlacklistJob.perform_later(user)
			end
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Users Blacklist successfully.')
	end

	def clearCacheEmailBlackList
		blackList = [];
		EmailDomainBlacklist::all.each do |email|
			blackList << email.domain
		end
		Rails.cache.delete("email_black_list")
		Rails.cache.fetch("email_black_list") do
			blackList
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Email Black List successfully.')
	end

	def clearCacheBlackList
		blackList = [];
		MobifoneBlacklist::all.each do |number|
			blackList << number.sub_id
		end
		Rails.cache.delete("black_list")
		Rails.cache.fetch("black_list") do
			blackList
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Black List successfully.')
	end

	def clearCacheRoomFeatured
		Rails.cache.delete("room_featured")
		Rails.cache.fetch("room_featured") do
			RoomFeatured.joins(broadcaster: :rooms).where('rooms.is_privated' => false).order('rooms.on_air desc, weight asc').limit(16)
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Room Featured successfully.')
	end

	def clearCacheTopWeek
		WeeklyTopBctReceivedHeart.destroy_all
		WeeklyTopBctReceivedHeart.connection.execute("ALTER TABLE top_bct_received_hearts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).group(:room_id).order('quantity DESC').limit(5)
		hearts.each do |heart|
			WeeklyTopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end
		Rails.cache.delete("top_broadcaster_revcived_heart_week")
		Rails.cache.fetch("top_broadcaster_revcived_heart_week") do
			WeeklyTopBctReceivedHeart::all
		end

		WeeklyTopUserSendGift.destroy_all
		WeeklyTopUserSendGift.connection.execute("ALTER TABLE weekly_top_user_send_gifts AUTO_INCREMENT = 1")
		weekly_user_logs = UserLog.select('user_id, sum(money) as money').where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).group(:user_id).order('money DESC').limit(5)
		weekly_user_logs.each do |weekly_user_log|
			WeeklyTopUserSendGift.create(:user_id => weekly_user_log.user_id, :money => weekly_user_log.money)
		end
		Rails.cache.delete("top_user_send_gift_week")
		Rails.cache.fetch("top_user_send_gift_week") do
			WeeklyTopUserSendGift::all
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Top Week successfully.')
	end

	def clearCacheTopMonth
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
		redirect_to({ action: 'index' }, notice: 'Clear Cache Top Month successfully.')
	end

	def clearCacheTopAll
		TopBctReceivedHeart.destroy_all
		TopBctReceivedHeart.connection.execute("ALTER TABLE top_user_send_gifts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').group(:room_id).order('quantity DESC').limit(5)
		hearts.each do |heart|
			TopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end
		Rails.cache.delete("top_broadcaster_revcived_heart_all")
		Rails.cache.fetch("top_broadcaster_revcived_heart_all") do
			TopBctReceivedHeart::all
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Top All successfully.')
	end

	def clearCacheVip
		Vip.all.each do |vip|
			$redis.del "vip:#{vip.weight}"
			fetch_vip vip.weight
		end
		redirect_to({ action: 'index' }, notice: 'Clear Cache Vip successfully.')
	end

	def edit_tim_bct
		logbct = BctTimeLog.all.where(:created_at=>Time.parse("2016-11-30 12:56:00 +0700")..Time.parse("2016-12-22 15:57:00 +0700")).order('id desc')
		logbct.each do |iteamLog|
			timeStart = iteamLog.start_room + 7.hours
			timeEnd = iteamLog.end_room != nil ? iteamLog.end_room + 7.hours : nil
			iteamLog.update(:start_room => timeStart, :end_room => timeEnd)
		end
        redirect_to({ action: 'index' }, notice: 'Edit time successfully.')
	end

end
