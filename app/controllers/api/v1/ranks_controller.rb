class Api::V1::RanksController < Api::V1::ApplicationController
	include Api::V1::Authorize
	include KrakenHelper

	before_action :authenticate, only: [:userRanking]

	def userRanking
		if @user.is_broadcaster
			if total_hearts_received = TopBctReceivedHeart.select("sum(quantity) as total").where(broadcaster_id: @user.broadcaster.id).group(:broadcaster_id).take
				@total_hearts = total_hearts_received.total
				@received_hearts = TopBctReceivedHeart.group(:broadcaster_id).having("sum(quantity) > ?", @total_hearts).count.count + 1
			else
				@total_hearts = @received_hearts = 0
			end

			if money_gifts_received = MonthlyTopBctReceivedGift.select("sum(money) as money").where(broadcaster_id: @user.broadcaster.id).group(:broadcaster_id).take
				@total_money = money_gifts_received.money
				@received_gifts = MonthlyTopBctReceivedGift.group(:broadcaster_id).having("sum(money) > ?", @total_money).count.count + 1
			else
				@total_money = @received_gifts = 0
			end

			if times_level_ups = TopBctLevelUp.select("sum(times) as times").where(broadcaster_id: @user.broadcaster.id).group(:broadcaster_id).take
				@times = times_level_ups.times
				@level_ups = TopBctLevelUp.group(:broadcaster_id).having("sum(times) > ?", @times).count.count + 1
			else
				@times = @level_ups = 0
			end
		else
			if money_gifts_send = TopUserSendGift.select("sum(money) as money").where(user_id: @user.id).group(:user_id).take
				@total_money = money_gifts_send.money
				@send_gifts = TopUserSendGift.group(:user_id).having("sum(money) > ?", @total_money).count.count + 1
			else
				@total_money = @send_gifts = 0
			end
			
			if times_level_ups = TopUserLevelUp.select("sum(times) as times").where(user_id: @user.id).group(:user_id).take
				@times = times_level_ups.times
				@level_ups = TopUserLevelUp.group(:user_id).having("sum(times) > ?", @times).count.count + 1
			else
				@times = @level_ups = 0
			end
		end
	end

	def topBroadcasterRevcivedHeart
		if params[:range] == nil or params[:range] == "week"
			@top_heart = WeeklyTopBctReceivedHeart::all
		elsif params[:range] == "all"
			@top_heart = TopBctReceivedHeart::all
		elsif params[:range] == "month"
			@top_heart = MonthlyTopBctReceivedHeart::all
		else
			render json: {error: 'Range error !'}, status: 400
		end
	end

	def topBroadcasterRevcivedGift
		if params[:range] == nil or params[:range] == "week"
			@top_users = WeeklyTopUserSendGift::all
		elsif params[:range] == "month"
			@top_users = MonthlyTopUserSendGift::all
		else
			render json: {error: 'Range error !'}, status: 400
		end
	end

	def topUserSendGift
		if params[:range] == nil or params[:range] == "week"
			@top_gift_users = WeeklyTopUserSendGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_week.all_week).group(:broadcaster_id).order('total_money desc').limit(5)
		elsif params[:range] == "all"
			@top_gift_users = TopUserSendGift.select('*,sum(quantity) as quantity, sum(money) as total_money').group(:broadcaster_id).order('total_money desc').limit(5)
		elsif params[:range] == "month"
			@top_gift_users = MonthlyTopUserSendGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_month.all_month).group(:broadcaster_id).order('total_money desc').limit(5)
		else
			render json: {error: 'Range error !'}, status: 400
		end
	end

	def topBroadcasterLevelGrow
		if params[:range] == nil or params[:range] == "week"
			@top_broadcaster_level = WeeklyTopBctLevelUp.select('*,sum(times) as level').where(created_at: DateTime.now.prev_week.all_week).group(:broadcaster_id).order('times desc').limit(5)
		elsif params[:range] == "all"
			@top_broadcaster_level = TopBctLevelUp.select('*,sum(times) as level').group(:broadcaster_id).order('times desc').limit(5)
		elsif params[:range] == "month"
			@top_broadcaster_level = MonthlyTopBctLevelUp.select('*,sum(times) as level').where(created_at: DateTime.now.prev_month.all_month).group(:broadcaster_id).order('times desc').limit(5)
		else
			render json: {error: 'Range error !'}, status: 400
		end
	end

	def topUserLevelGrow
		if params[:range] == nil or params[:range] == "week"
			@top_user_level = WeeklyTopUserLevelUp.select('*,sum(times) as level').where(created_at: DateTime.now.prev_week.all_week).group(:user_id).order('times desc').limit(5)
		elsif params[:range] == "all"
			@top_user_level = TopUserLevelUp.select('*,sum(times) as level').group(:user_id).order('times desc').limit(5)
		elsif params[:range] == "month"
			@top_user_level = MonthlyTopUserLevelUp.select('*,sum(times) as level').where(created_at: DateTime.now.prev_month.beginning_of_month..DateTime.now.prev_month.end_of_month).group(:user_id).order('times desc').limit(5)
		else
			render json: {error: 'Range error !'}, status: 400
		end
	end

	def topUserFollowBroadcaster
		@top_fans = Broadcaster.find(params[:id]).users.order('users.money desc').limit(10)
	end

	def topUserUseMoneyRoom
	    @top_users = UserLog.select('*, sum(money) as money').where("room_id = ? AND created_at > ? AND created_at < ?", params[:room_id], 1.week.ago.beginning_of_week, 1.week.ago.end_of_week).group(:user_id).order('money desc').limit(3)
	    if @top_users.length < 1
	    	render status: 204
	    end
	end

	def topUserUseMoneyCurrent
		if params["on-air"] != true
			user_log = UserLog.where("room_id = ?", params[:room_id]).order("created_at desc").first
			if !user_log
				render status: 204
			else
				@top_users = UserLog.select('*, sum(money) as money').where("room_id = ? AND created_at > ? AND created_at < ?", params[:room_id], user_log.created_at.beginning_of_day.to_s, user_log.created_at.end_of_day.to_s).group(:user_id).order('money desc').limit(3)
			end
		else
			time = Time.now.to_s
			schedule = Room.find(params[:room_id]).schedules.where("start < ? AND ? < end", time, time).take
			if schedule
				@top_users = UserLog.select('*, sum(money) as money').where("room_id = ? AND created_at > ? AND created_at < ?", params[:room_id], schedule.start, schedule.end).group(:user_id).order('money desc').limit(3)
			else
				room = Room.find(params[:room_id])
				@top_users = UserLog.select('*, sum(money) as money').where("room_id = ? AND created_at > ? AND created_at < ?", params[:room_id], room.updated_at.to_s, time).group(:user_id).order('money desc').limit(3)
				if @top_users.length < 1
					render status: 204
				end
			end
		end
	end

	def topWeek
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
		return head 200
	end

	def topMonth
		MonthlyTopBctReceivedHeart.destroy_all
		MonthlyTopBctReceivedHeart.connection.execute("ALTER TABLE monthly_top_bct_received_hearts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').where(created_at: DateTime.now.beginning_of_month..DateTime.now).group(:room_id).order('quantity DESC').limit(5)
		hearts.each do |heart|
			MonthlyTopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end
		
		MonthlyTopUserSendGift.destroy_all
		MonthlyTopUserSendGift.connection.execute("ALTER TABLE monthly_top_user_send_gifts AUTO_INCREMENT = 1")
		monthly_user_logs = UserLog.select('user_id, sum(money) as money').where(created_at: DateTime.now.beginning_of_month..DateTime.now).group(:user_id).order('money DESC').limit(5)
		monthly_user_logs.each do |monthly_user_log|
			MonthlyTopUserSendGift.create(:user_id => monthly_user_log.user_id, :money => monthly_user_log.money)
		end
		return head 200
	end

	def topYear
		TopBctReceivedHeart.destroy_all
		TopBctReceivedHeart.connection.execute("ALTER TABLE top_user_send_gifts AUTO_INCREMENT = 1")
		hearts = HeartLog.select('room_id, sum(quantity) as quantity').group(:room_id).order('quantity DESC').limit(5)
		hearts.each do |heart|
			TopBctReceivedHeart.create(:broadcaster_id => heart.room.broadcaster.id, :quantity => heart.quantity)
		end
		return head 200
	end

	def updateNameEmailUserMBF
		users = MobifoneUser.all
		users.each do |umbf|
			umbf.user.update(name: umbf.user.phone.to_s[0,umbf.user.phone.to_s.length-3]+"xxx", email: umbf.user.email.to_s[0,umbf.user.email.to_s.length-15]+"livestar.vn")
		end
		return head 200
	end

	def optimizeImage
		User.all.each do |user|
			if user.id == 197
				if user.avatar != '' || user.avatar != nil
					avatarUrl 		= user.avatar_path
					Rails.logger.info "ANGCO DEBUG file: #{file.path}"
					linkFile = uploadDowload(avatarUrl)
					user.remote_avatar_url = linkFile
					check = user.save
					Rails.logger.info "ANGCO ---------------------------------------------------------------------- Check: #{check}"
				end
				# if user.avatar_crop != '' || user.avatar_crop != nil
				# 	avatarCropUrl 	= 'uploads/user/avatar_crop/'+ user.id.to_s + user.avatar_crop.to_s
				# 	uploadDowload(avatarCropUrl)
				# end
				# if user.cover != '' || user.cover != nil
				# 	coverUrl 		= 'uploads/user/cover/'+ user.id.to_s + user.cover.to_s
				# 	uploadDowload(coverUrl)
				# end
				# if user.cover_crop != '' || user.cover_crop != nil
				# 	coverCropUrl 	= 'uploads/user/cover_crop/'+ user.id.to_s + user.cover_crop.to_s
				# 	uploadDowload(coverCropUrl)
				# end
			end
		end
		return head 200
	end

	def updateCreatedAtBroadcaster
	end
end