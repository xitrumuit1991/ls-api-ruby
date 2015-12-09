class Api::V1::RanksController < Api::V1::ApplicationController
	# include Api::V1::Authorize
	# before_action :authenticate

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
			@top_gift_broadcasters = WeeklyTopBctReceivedGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_week.all_week).group(:broadcaster_id).order('quantity desc').limit(5)
		elsif params[:range] == "all"
			@top_gift_broadcasters = TopBctReceivedGift.select('*,sum(quantity) as quantity, sum(money) as total_money').group(:broadcaster_id).order('quantity desc').limit(5)
		elsif params[:range] == "month"
			@top_gift_broadcasters = MonthlyTopBctReceivedGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_month.all_month).group(:broadcaster_id).order('quantity desc').limit(5)
		else
			render plain: 'Range error !', status: 400
		end
	end

	def topUserSendGift
		if params[:range] == nil or params[:range] == "week"
			@top_gift_users = WeeklyTopUserSendGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_week.all_week).group(:broadcaster_id).order('quantity desc').limit(5)
		elsif params[:range] == "all"
			@top_gift_users = TopUserSendGift.select('*,sum(quantity) as quantity, sum(money) as total_money').group(:broadcaster_id).order('quantity desc').limit(5)
		elsif params[:range] == "month"
			@top_gift_users = MonthlyTopUserSendGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_month.all_month).group(:broadcaster_id).order('quantity desc').limit(5)
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

	def topUserSendGiftRoom
	    if params[:room] != nil and (params[:range] == nil or params[:range] == "week")
	    	@top_gift_users = WeeklyTopUserSendGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(room_id: params[:room].to_i, created_at: DateTime.now.prev_week.all_week).group(:user_id).order('quantity desc').limit(3)
	    end
	end

	def topUserFollowBroadcaster
		@top_fans = Broadcaster.find(params[:id]).users.order('users.money desc').limit(10)
	end

	def updateCreatedAtBroadcaster
		WeeklyTopBctReceivedHeart.update_all(:created_at => DateTime.now.prev_week)
		MonthlyTopBctReceivedHeart.update_all(:created_at => DateTime.now.prev_month)

		WeeklyTopBctReceivedGift.update_all(:created_at => DateTime.now.prev_week)
		MonthlyTopBctReceivedGift.update_all(:created_at => DateTime.now.prev_month)

		WeeklyTopBctLevelUp.update_all(:created_at => DateTime.now.prev_week)
		MonthlyTopBctLevelUp.update_all(:created_at => DateTime.now.prev_month)
		
		WeeklyTopUserLevelUp.update_all(:created_at => DateTime.now.prev_week)
		MonthlyTopUserLevelUp.update_all(:created_at => DateTime.now.prev_month)

		WeeklyTopUserSendGift.update_all(:created_at => DateTime.now.prev_week)
		render plain: 'Done !', status: 200
	end
end