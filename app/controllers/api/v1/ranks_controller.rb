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
		@top_heart = Broadcaster.order(recived_heart: :desc).limit(10)
	end

	def topLevelGrowBroadcaster
		@top_broadcaster_level = Broadcaster.order(broadcaster_exp: :desc).limit(10)
	end

	def topLevelGrowUser
		@top_user_level = User.order(user_exp: :desc).limit(10)
	end

end