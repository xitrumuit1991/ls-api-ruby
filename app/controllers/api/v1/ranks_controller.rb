class Api::V1::RanksController < Api::V1::ApplicationController
	include Api::V1::Authorize

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
			@top_heart = WeeklyTopBctReceivedHeart.select('*,sum(quantity) as quantity').where(created_at: DateTime.now.prev_week.all_week).group(:broadcaster_id).order('quantity desc').limit(5)
		elsif params[:range] == "all"
			@top_heart = TopBctReceivedHeart.select('*,sum(quantity) as quantity').group(:broadcaster_id).order('quantity desc').limit(5)
		elsif params[:range] == "month"
			@top_heart = MonthlyTopBctReceivedHeart.select('*,sum(quantity) as quantity').where(created_at: DateTime.now.prev_month.all_month).group(:broadcaster_id).order('quantity desc').limit(5)
		else
			render plain: 'Range error !', status: 400
		end
	end

	def topBroadcasterRevcivedGift
		if params[:range] == nil or params[:range] == "week"
			@top_gift_broadcasters = WeeklyTopBctReceivedGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_week.all_week).group(:broadcaster_id).order('total_money desc').limit(5)
		elsif params[:range] == "all"
			@top_gift_broadcasters = TopBctReceivedGift.select('*,sum(quantity) as quantity, sum(money) as total_money').group(:broadcaster_id).order('total_money desc').limit(5)
		elsif params[:range] == "month"
			@top_gift_broadcasters = MonthlyTopBctReceivedGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_month.all_month).group(:broadcaster_id).order('total_money desc').limit(5)
		else
			render plain: 'Range error !', status: 400
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
			render plain: 'Range error !', status: 400
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
			render plain: 'Range error !', status: 400
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
			render plain: 'Range error !', status: 400
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
			@top_users = UserLog.select('*, sum(money) as money').where("room_id = ? AND created_at > ? AND created_at < ?", params[:room_id], user_log.created_at.beginning_of_day.to_s, user_log.created_at.end_of_day.to_s).group(:user_id).order('money desc').limit(3)
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

	def updateCreatedAtBroadcaster
		# WeeklyTopBctReceivedHeart.update_all(:created_at => DateTime.now.prev_week)
		# MonthlyTopBctReceivedHeart.update_all(:created_at => DateTime.now.prev_month)

		# WeeklyTopBctReceivedGift.update_all(:created_at => DateTime.now.prev_week)
		# MonthlyTopBctReceivedGift.update_all(:created_at => DateTime.now.prev_month)

		# WeeklyTopBctLevelUp.update_all(:created_at => DateTime.now.prev_week)
		# MonthlyTopBctLevelUp.update_all(:created_at => DateTime.now.prev_month)
		
		# WeeklyTopUserLevelUp.update_all(:created_at => DateTime.now.prev_week)
		# MonthlyTopUserLevelUp.update_all(:created_at => DateTime.now.prev_month)

		# WeeklyTopUserSendGift.update_all(:created_at => DateTime.now.prev_week)
		# Schedule.update_all(:end => '2016-10-16 06:47:44')
		User.update_all(:money => 100000, :actived => 1)
		render plain: 'Done !', status: 200
	end
end