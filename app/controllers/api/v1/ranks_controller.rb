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
			@top_heart = Rails.cache.fetch('top_broadcaster_revcived_heart_week')
		elsif params[:range] == "all"
			@top_heart = Rails.cache.fetch('top_broadcaster_revcived_heart_all')
		elsif params[:range] == "month"
			@top_heart = Rails.cache.fetch('top_broadcaster_revcived_heart_month')
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
			@top_gift_users = Rails.cache.fetch('top_user_send_gift_week')
		elsif params[:range] == "month"
			@top_gift_users = Rails.cache.fetch('top_user_send_gift_month')
		else
			render json: {error: 'Range error !'}, status: 400
		end
	end

	def topBroadcasterLevelGrow
		if params[:range] == nil or params[:range] == "week"
			@top_broadcaster_level = WeeklyTopBctLevelUp.order('times desc').limit(5)
		elsif params[:range] == "all"
			@top_broadcaster_level = TopBctLevelUp.order('times desc').limit(5)
		elsif params[:range] == "month"
			@top_broadcaster_level = MonthlyTopBctLevelUp.order('times desc').limit(5)
		else
			render json: {error: 'Range error !'}, status: 400
		end
	end

	def topUserLevelGrow
		if params[:range] == nil or params[:range] == "week"
			@top_user_level = WeeklyTopUserLevelUp.order('times desc').limit(5)
		elsif params[:range] == "all"
			@top_user_level = TopUserLevelUp.order('times desc').limit(5)
		elsif params[:range] == "month"
			@top_user_level = MonthlyTopUserLevelUp.order('times desc').limit(5)
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

	def updateNameEmailUserMBF
		users = MobifoneUser.all
		users.each do |umbf|
			umbf.user.update(name: umbf.user.phone.to_s[0,umbf.user.phone.to_s.length-3]+"xxx", email: umbf.user.email.to_s[0,umbf.user.email.to_s.length-15]+"livestar.vn")
		end
		return head 200
	end

	def optimizeImageUsers
		User.all.each do |user|
			if user.avatar_crop != nil
				OptimizeImageJob.perform_later(user, 'users', request.base_url)
			end
		end
		return head 200
	end

	def optimizeImageRooms
		Room.all.each do |room|
			if room.thumb_crop != nil
				OptimizeImageJob.perform_later(room, 'rooms', request.base_url)
			end
		end
		return head 200
	end

	def optimizeImageBctImage
		BctImage.all.each do |bct_image|
			if bct_image.image != nil
				OptimizeImageJob.perform_later(bct_image, 'bct-image', request.base_url)
			end
		end
		return head 200
	end

	def optimizeImageBctVideo
		BctVideo.all.each do |bct_video|
			if bct_video.thumb != nil
				OptimizeImageJob.perform_later(bct_video, 'bct-video', request.base_url)
			end
		end
		return head 200
	end

	def optimizeImageBctBackground
		BroadcasterBackground.all.each do |bct_bg|
			if bct_bg.image != nil
				OptimizeImageJob.perform_later(bct_bg, 'bct-bg', request.base_url)
			end
		end
		return head 200
	end

	def optimizeGift
		Gift.all.each do |gift|
			if gift.image != nil
				OptimizeImageJob.perform_later(gift, 'gift', request.base_url)
			end
		end
		return head 200
	end

	def optimizePoster
		Poster.all.each do |poster|
			if poster.thumb != nil
				OptimizeImageJob.perform_later(poster, 'poster', request.base_url)
			end
		end
		return head 200
	end

	def optimizeImageRoomAction
		RoomAction.all.each do |room_action|
			if room_action.image != nil
				OptimizeImageJob.perform_later(room_action, 'room-action', request.base_url)
			end
		end
		return head 200
	end

	def optimizeRoomBackground
		RoomBackground.all.each do |room_background|
			if room_background.image != nil
				OptimizeImageJob.perform_later(room_background, 'room-bg', request.base_url)
			end
		end
		return head 200
	end

	def optimizeImageSlide
		Slide.all.each do |slide|
			if slide.banner != nil
				OptimizeImageJob.perform_later(slide, 'slide', request.base_url)
			end
		end
		return head 200
	end

	def optimizeImageVip
		Vip.all.each do |vip|
			if vip.image != nil
				OptimizeImageJob.perform_later(vip, 'vip', request.base_url)
			end
		end
		return head 200
	end
end