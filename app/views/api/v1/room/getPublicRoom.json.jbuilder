json.id					@room.id
json.room_type_id		@room.room_type_id
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
json.bct_background_id @room.broadcaster_background_id
json.room_background_id @room.room_background_id

json.broadcaster do
	json.broadcaster_id	@room.broadcaster.id
	json.user_id		@room.broadcaster.user.id
	json.avatar     @room.broadcaster.user.avatar_path[:avatar]
    json.avatar_w60h60      @room.broadcaster.user.avatar_path[:avatar_w60h60]
    json.avatar_w100h100    @room.broadcaster.user.avatar_path[:avatar_w100h100]
    json.avatar_w120h120    @room.broadcaster.user.avatar_path[:avatar_w120h120]
    json.avatar_w200h200    @room.broadcaster.user.avatar_path[:avatar_w200h200]
    json.avatar_w240h240    @room.broadcaster.user.avatar_path[:avatar_w240h240]
    json.avatar_w300h300    @room.broadcaster.user.avatar_path[:avatar_w300h300]
    json.avatar_w400h400    @room.broadcaster.user.avatar_path[:avatar_w400h400]
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
  json.description					@room.broadcaster.description
end

json.schedules @room.schedules do |schedule|
  json.id schedule.id
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

#Load gift
json.gifts @gifts do |gift|
  json.id							gift.id
  json.name						gift.name
  json.image					gift.image_path[:image]
	json.image_w50h50		gift.image_path[:image_w50h50]
	json.image_w100h100	gift.image_path[:image_w100h100]
	json.image_w200h200	gift.image_path[:image_w200h200]
  json.price					gift.price
end

#Load action
json.actions @actions do |action|
  json.id							action.id
  json.name						action.name
  json.image					action.image_path[:image]
	json.image_w50h50		action.image_path[:image_w50h50]
	json.image_w100h100	action.image_path[:image_w100h100]
	json.image_w200h200	action.image_path[:image_w200h200]
  json.price					action.price
end

json.gifts_selected @arrGiftSelected
json.action_selected @arrActionSelected