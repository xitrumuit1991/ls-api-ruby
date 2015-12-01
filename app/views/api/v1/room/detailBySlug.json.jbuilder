json.id					@room.id
json.title				@room.title
json.slug				@room.slug
json.thumb				"#{request.base_url}#{@room.thumb.thumb.url}"
json.thumb_mb			"#{request.base_url}#{@room.thumb.thumb_mb.url}"
json.is_privated		@room.is_privated
json.on_air				@room.on_air
json.link_stream		"rtmp://210.245.18.154:80/livemix/android/playlist.m3u8"

if !@room.broadcaster_background_id.nil?
	if !@room.broadcaster_background_id.nil?
		json.background 	@room.broadcaster_background.image.url
	else
		json.background 	false
	end
else
	if !@room.room_background_id.nil? 
		json.background 	@room.room_background.image.url
	else
		json.background 	false
	end
end

if !@tmp_token.nil?
	json.tmp_token @tmp_token
end

if !@tmp_user.nil?
	json.tmp_user @tmp_user
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
	if @user != nil
		json.isFollow		!@user.broadcasters.where(broadcaster_id: @room.broadcaster.id).nil?
	else
		json.isFollow		false
	end
end

json.schedules @room.schedules do |schedule|
	json.date	schedule.start.strftime('%d/%m/%Y')
	json.start	schedule.start.strftime('%H:%M')
	json.end	schedule.end.strftime('%H:%M')
end