json.id					@room.id
json.room_type_id		@room.room_type_id
json.title				@room.title
json.slug				@room.slug
json.thumb				"#{request.base_url}#{@room.thumb.thumb}"
json.thumb_mb			"#{request.base_url}#{@room.thumb.thumb_mb}"
json.is_privated		@room.is_privated
if !@room.broadcaster_background_id.nil?
	if !@room.broadcaster_background_id.nil?
		json.background 	@room.broadcaster_background.image.url
    json.background_id @room.broadcaster_background.id
	else
		json.background 	false
    json.background_id false
	end
else
	if !@room.room_background_id.nil? 
		json.background 	@room.room_background.image.url
    json.background_id @room.room_background.id
	else
		json.background 	false
    json.background_id false
	end
end

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
	json.start_date	schedule.start.strftime('%d/%m/%Y')
	json.end_date	schedule.end.strftime('%d/%m/%Y')
	json.start	schedule.start.strftime('%H:%M')
	json.end	schedule.end.strftime('%H:%M')
end

json.backgrounds @backgrounds do |background|
	json.id		background.id
	json.thumb	"#{request.base_url}#{background.image.square}"
end

json.bct_backgrounds @bct_backgrounds do |bct_background|
	json.id		bct_background.id
	json.thumb	"#{request.base_url}#{bct_background.image.square}"
end