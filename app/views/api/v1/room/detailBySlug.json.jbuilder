json.id					@room.id
json.title				@room.title
json.slug				@room.slug

json.thumb              replaceThumbCrop(@room.id, @room.thumb_path[:thumb] )
json.thumb_mb           replaceThumbCrop(@room.id, @room.thumb_path[:thumb_w720h405] )
json.thumb_w160h190     replaceThumbCrop(@room.id, @room.thumb_path[:thumb_w160h190] ) 
json.thumb_w240h135     replaceThumbCrop(@room.id, @room.thumb_path[:thumb_w240h135] ) 
json.thumb_w320h180     replaceThumbCrop(@room.id, @room.thumb_path[:thumb_w320h180] ) 
json.thumb_w720h405     replaceThumbCrop(@room.id, @room.thumb_path[:thumb_w720h405] ) 
json.thumb_w768h432     replaceThumbCrop(@room.id, @room.thumb_path[:thumb_w768h432] ) 
json.thumb_w960h540     replaceThumbCrop(@room.id, @room.thumb_path[:thumb_w960h540] ) 


json.is_privated		@room.is_privated
json.on_air				@room.on_air
json.link_stream		"http://stream.livestar.vn:80/livestar-open/#{@room.id}/playlist.m3u8"

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
	json.avatar     	@room.broadcaster.user.avatar_path[:avatar]
	json.avatar_w60h60      @room.broadcaster.user.avatar_path[:avatar_w60h60]
	json.avatar_w100h100    @room.broadcaster.user.avatar_path[:avatar_w100h100]
	json.avatar_w120h120    @room.broadcaster.user.avatar_path[:avatar_w120h120]
	json.avatar_w200h200    @room.broadcaster.user.avatar_path[:avatar_w200h200]
	json.avatar_w240h240    @room.broadcaster.user.avatar_path[:avatar_w240h240]
	json.avatar_w300h300    @room.broadcaster.user.avatar_path[:avatar_w300h300]
	json.avatar_w400h400    @room.broadcaster.user.avatar_path[:avatar_w400h400]
	json.cover              @room.broadcaster.user.cover_path[:cover]
	json.cover_w940h200		@room.broadcaster.user.cover_path[:cover_w940h200]
	json.name			@room.broadcaster.user.name
	json.description	@room.broadcaster.description.gsub(/(\r\n|\n|\r|'|")/, '')
	json.username		@room.broadcaster.user.username
	json.heart			@room.broadcaster.recived_heart
	json.exp			@room.broadcaster.broadcaster_exp
	json.percent		@room.broadcaster.percent
	json.level			@room.broadcaster.broadcaster_level.level
  json.facebook		@room.broadcaster.user.facebook_link
  json.twitter		@room.broadcaster.user.twitter_link
  json.instagram		@room.broadcaster.user.instagram_link
	json.status			@room.broadcaster.user.statuses.blank? ? nil : @room.broadcaster.user.statuses[0].content
	if @user != nil
		json.isFollow		!@user.broadcasters.where(id: @room.broadcaster.id).empty?
	else
		json.isFollow		false
	end
end

json.schedules @room.schedules do |schedule|
	json.date	schedule.start ? schedule.start.strftime('%d/%m/%Y') : nil
	json.start 	schedule.start ? schedule.start.strftime('%H:%M') : nil
	json.end	schedule.end ? schedule.end.strftime('%H:%M') : nil
end