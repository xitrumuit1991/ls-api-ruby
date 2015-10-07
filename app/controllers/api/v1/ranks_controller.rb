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