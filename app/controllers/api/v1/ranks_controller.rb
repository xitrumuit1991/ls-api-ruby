class Api::V1::RanksController < Api::V1::ApplicationController
	include Api::V1::Authorize
	before_action :authenticate

	def getFeaturedBroadcasters
		
	end

	def topGiftBroadcaster
		
	end

	def topGiftBroadcaster

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