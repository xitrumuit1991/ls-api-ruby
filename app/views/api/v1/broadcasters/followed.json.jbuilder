if @users_followed.present?
	json.array! @users_followed do |followed|
		json.id					followed ? followed.id : nil
		json.name				(followed && followed.user) ? followed.user.name : nil
		json.username	 	(followed && followed.user) ? followed.user.username : nil
		json.avatar     				followed.user.avatar_path[:avatar]
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
			json.id				(followed && followed.public_room) ? followed.public_room.id : nil
			json.title		(followed && followed.public_room) ? followed.public_room.title : nil
			json.slug			(followed && followed.public_room) ? followed.public_room.slug : nil
			json.on_air		(followed && followed.public_room) ? followed.public_room.on_air : nil
			json.thumb             (followed && followed.public_room) ? followed.public_room.thumb_path[:thumb] : nil 
			json.thumb_mb          (followed && followed.public_room) ? followed.public_room.thumb_path[:thumb_w720h405]  : nil
			json.thumb_w160h190    (followed && followed.public_room) ? followed.public_room.thumb_path[:thumb_w160h190] : nil
			json.thumb_w240h135    (followed && followed.public_room) ? followed.public_room.thumb_path[:thumb_w240h135] : nil
			json.thumb_w320h180    (followed && followed.public_room) ? followed.public_room.thumb_path[:thumb_w320h180] : nil
			json.thumb_w720h405    (followed && followed.public_room) ? followed.public_room.thumb_path[:thumb_w720h405] : nil
			json.thumb_w768h432    (followed && followed.public_room) ? followed.public_room.thumb_path[:thumb_w768h432] : nil
			json.thumb_w960h540    (followed && followed.public_room) ? followed.public_room.thumb_path[:thumb_w960h540] : nil
		end
		if followed && followed.public_room
			if !followed.public_room.on_air and followed.public_room.schedules.length > 0
				json.schedule do
					json.date followed.public_room.schedules.last.start.strftime('%d/%m')
					json.start followed.public_room.schedules.last.start.strftime('%H:%M')
				end
			else
				json.schedule nil
			end
		else
			json.schedule nil
		end
	end
end