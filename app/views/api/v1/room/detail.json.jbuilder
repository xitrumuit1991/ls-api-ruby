json.id					@room.id
json.title				@room.title
json.slug				@room.slug
json.thumb				@room.thumb.url.to_s
json.background			@room.background.url.to_s
json.is_privated		@room.is_privated

json.broadcaster do
	json.broadcaster_id	@room.broadcaster.id
	json.user_id		@room.broadcaster.user.id
	json.avatar			"#{request.base_url}/api/v1/users/#{@room.broadcaster.user.id}/avatar"
	json.name			@room.broadcaster.user.name
	json.heart			@room.broadcaster.recived_heart
	json.exp			@room.broadcaster.broadcaster_exp
	json.percent		@room.broadcaster.percent
	json.level			@room.broadcaster.broadcaster_level.level
	json.facebook		@room.broadcaster.user.facebook_link
	json.twitter		@room.broadcaster.user.twitter_link
	json.instagram		@room.broadcaster.user.instagram_link
	json.status			@room.broadcaster.user.statuses.blank? ? nil : @room.broadcaster.user.statuses[0].content
	json.isFollow		!@user.broadcasters.where(id: @room.broadcaster.id).empty?
end

json.schedules @room.schedules do |schedule|
	json.date	schedule.start.strftime('%d/%m/%Y')
	json.start	schedule.start.strftime('%H:%M')
	json.end	schedule.end.strftime('%H:%M')
end