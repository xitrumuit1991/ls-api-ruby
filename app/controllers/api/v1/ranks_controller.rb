class Api::V1::RanksController < Api::V1::ApplicationController
	include Api::V1::Authorize
	before_action :authenticate

	def getFeaturedBroadcasters
		@featured = Featured.order(weight: :asc).limit(6)
	end

	def homeGetFeaturedBroadcasters
		@featured = HomeFeatured.order(weight: :asc).limit(5)
	end

	def roomGetFeaturedBroadcasters
		@featured = RoomFeatured.order(weight: :asc).limit(10)
	end

	def topGiftBroadcaster
		if params[:range] == "month"
			@top_gift_broadcasters = GiftLog.select('*,sum(quantity) as quantity , sum(cost) as total_money').where(updated_at: 1.month.ago..DateTime.now , user_id: nil).group(:room_id).order('quantity desc').limit(10)
		elsif params[:range] == "all"
			@top_gift_broadcasters = GiftLog.select('*,sum(quantity) as quantity , sum(cost) as total_money').where(user_id: nil).group(:room_id).order('quantity desc').limit(10)
		else
			@top_gift_broadcasters = GiftLog.select('*,sum(quantity) as quantity , sum(cost) as total_money').where(updated_at: 1.week.ago..DateTime.now , user_id: nil).group(:room_id).order('quantity desc').limit(10)
		end
	end

	def topGiftUser
		if params[:range] == "month"
			@top_gift_users = GiftLog.select('*,sum(quantity) as quantity , sum(cost) as total_money').where(updated_at: 1.month.ago..DateTime.now , room_id: nil).group(:user_id).order('quantity desc').limit(10)
		elsif params[:range] == "all"
			@top_gift_users = GiftLog.select('*,sum(quantity) as quantity , sum(cost) as total_money').where(room_id: nil).group(:user_id).order('quantity desc').limit(10)
		else
			@top_gift_users = GiftLog.select('*,sum(quantity) as quantity , sum(cost) as total_money').where(updated_at: 1.week.ago..DateTime.now , room_id: nil).group(:user_id).order('quantity desc').limit(10)
		end
	end

	def topHeartBroadcaster
		if params[:range] == "month"
			@top_heart = Broadcaster.where(updated_at: 1.month.ago..DateTime.now).order(recived_heart: :desc).limit(10)
		elsif params[:range] == "all"
			@top_heart = Broadcaster.order(recived_heart: :desc).limit(10)
		else
			@top_heart = Broadcaster.where(updated_at: 1.week.ago..DateTime.now).order(recived_heart: :desc).limit(10)
		end
	end

	def topLevelGrowBroadcaster
		if params[:range] == "month"
			@top_broadcaster_level = Broadcaster.where(updated_at: 1.month.ago..DateTime.now).order(broadcaster_exp: :desc).limit(10)
		elsif params[:range] == "all"
			@top_broadcaster_level = Broadcaster.order(broadcaster_exp: :desc).limit(10)
		else
			@top_broadcaster_level = Broadcaster.where(updated_at: 1.week.ago..DateTime.now).order(broadcaster_exp: :desc).limit(10)
		end
	end

	def topLevelGrowUser
		if params[:range] == "month"
			@top_user_level = User.where(updated_at: 1.month.ago..DateTime.now).order(user_exp: :desc).limit(10)
		elsif params[:range] == "all"
			@top_user_level = User.order(user_exp: :desc).limit(10)
		else
			@top_user_level = User.where(updated_at: 1.week.ago..DateTime.now).order(user_exp: :desc).limit(10)
		end
	end

end