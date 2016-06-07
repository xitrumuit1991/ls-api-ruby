json.totalPage @max_page
json.broadcasters @bcts do |bct|
	json.id			bct.id
	json.name		bct.user.name
	json.username	bct.user.username
	json.avatar     bct.user.avatar_path[:avatar]
    json.avatar_w60h60      bct.user.avatar_path[:avatar_w60h60]
    json.avatar_w100h100    bct.user.avatar_path[:avatar_w100h100]
    json.avatar_w120h120    bct.user.avatar_path[:avatar_w120h120]
    json.avatar_w200h200    bct.user.avatar_path[:avatar_w200h200]
    json.avatar_w240h240    bct.user.avatar_path[:avatar_w240h240]
    json.avatar_w300h300    bct.user.avatar_path[:avatar_w300h300]
    json.avatar_w400h400    bct.user.avatar_path[:avatar_w400h400]
	json.heart		bct.user.no_heart
	json.user_exp	bct.user.user_exp
	if !bct.user.user_level.nil?
		json.level		bct.user.user_level.level
	end
	if @user != nil
    json.isFollow		!@user.broadcasters.where(id: bct.id).empty?
  else
    json.isFollow		false
  end
	if bct.public_room.present?
		json.room do
			json.id				bct.public_room.id
      json.totalUser		@totalUser[bct.public_room.id]
			json.title		bct.public_room.title
			json.slug		bct.public_room.slug
			json.on_air		bct.public_room.on_air
			json.thumb             bct.public_room.thumb_path[:thumb]
			json.thumb_mb          bct.public_room.thumb_path[:thumb_w720h405]
			json.thumb_w160h190    bct.public_room.thumb_path[:thumb_w160h190]
			json.thumb_w240h135    bct.public_room.thumb_path[:thumb_w240h135]
			json.thumb_w320h180    bct.public_room.thumb_path[:thumb_w320h180]
			json.thumb_w720h405    bct.public_room.thumb_path[:thumb_w720h405]
			json.thumb_w768h432    bct.public_room.thumb_path[:thumb_w768h432]
			json.thumb_w960h540    bct.public_room.thumb_path[:thumb_w960h540]
		end
		if !bct.public_room.on_air and bct.public_room.schedules.length > 0
			json.schedule do
				json.date bct.public_room.schedules.last.start.strftime('%d/%m')
				json.start bct.public_room.schedules.last.start.strftime('%H:%M')
			end
		else
			json.schedule nil
		end
	else
		json.room nil
		json.schedule nil
	end
end