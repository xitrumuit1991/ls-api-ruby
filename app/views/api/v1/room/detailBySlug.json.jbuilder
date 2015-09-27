json.id					@room.id
json.title				@room.title
json.slug				@room.slug
json.thumb				@room.thumb
json.background			@room.background
json.is_privated		@room.is_privated

json.broadcaster do
	json.id				@room.broadcaster.user.id
	json.name			@room.broadcaster.user.name
	json.heart			@room.broadcaster.recived_heart
	json.exp			@room.broadcaster.broadcaster_exp
	json.level			@room.broadcaster.broadcaster_level.level
	json.facebook		@room.broadcaster.user.facebook_link
	json.twitter		@room.broadcaster.user.twitter_link
	json.instagram		@room.broadcaster.user.instagram_link
	json.status			@room.broadcaster.user.statuses.blank? ? nil : @room.broadcaster.user.statuses[0].content
end

json.schedules @room.schedules do |schedule|
	json.id				schedule.date
	json.from			schedule.start
	json.to				schedule.end
end