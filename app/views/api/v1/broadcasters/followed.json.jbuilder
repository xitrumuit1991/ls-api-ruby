if !@rusers_followed.present?
	json.array! @users_followed do |followed|
		json.id			followed.id
		json.name		followed.user.name
		json.username	followed.user.username
		json.avatar     followed.user.avatar_path[:avatar]
	    json.avatar_w60h60      followed.user.avatar_path[:avatar_w60h60]
	    json.avatar_w100h100    followed.user.avatar_path[:avatar_w100h100]
	    json.avatar_w120h120    followed.user.avatar_path[:avatar_w120h120]
	    json.avatar_w200h200    followed.user.avatar_path[:avatar_w200h200]
	    json.avatar_w240h240    followed.user.avatar_path[:avatar_w240h240]
	    json.avatar_w300h300    followed.user.avatar_path[:avatar_w300h300]
	    json.avatar_w400h400    followed.user.avatar_path[:avatar_w400h400]
		json.heart		followed.user.no_heart
		json.user_exp	followed.user.user_exp
		json.bct_exp	followed.broadcaster_exp
		json.level		followed.user.user_level.level
		json.room do
			json.id				followed.public_room.id
			json.title		followed.public_room.title
			json.slug			followed.public_room.slug
			json.on_air		followed.public_room.on_air
			json.thumb             followed.public_room.thumb_path[:thumb]
			json.thumb_mb          followed.public_room.thumb_path[:thumb_w960h540]
			json.thumb_w160h190    followed.public_room.thumb_path[:thumb_w160h190]
			json.thumb_w240h135    followed.public_room.thumb_path[:thumb_w240h135]
			json.thumb_w320h180    followed.public_room.thumb_path[:thumb_w320h180]
			json.thumb_w720h405    followed.public_room.thumb_path[:thumb_w720h405]
			json.thumb_w768h432    followed.public_room.thumb_path[:thumb_w768h432]
			json.thumb_w960h540    followed.public_room.thumb_path[:thumb_w960h540]
		end
		if !followed.public_room.on_air and followed.public_room.schedules.length > 0
			json.schedule do
				json.date followed.public_room.schedules.last.start.strftime('%d/%m')
				json.start followed.public_room.schedules.last.start.strftime('%H:%M')
			end
		else
			json.schedule nil
		end
	end
end