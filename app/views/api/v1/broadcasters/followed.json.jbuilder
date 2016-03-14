if !@rusers_followed.present?
	json.array! @users_followed do |followed|
		json.id			followed.id
		json.name		followed.user.name
		json.username	followed.user.username
		json.avatar		followed.user.avatar_path
		json.heart		followed.user.no_heart
		json.user_exp	followed.user.user_exp
		json.bct_exp	followed.broadcaster_exp
		json.level		followed.user.user_level.level
		json.room do
			json.id				followed.public_room.id
			json.title		followed.public_room.title
			json.slug			followed.public_room.slug
			json.on_air		followed.public_room.on_air
			json.thumb		followed.public_room.thumb_path
			json.thumb_mb	followed.public_room.thumb_path(true)
		end
		if !followed.public_room.on_air and followed.public_room.schedules.length > 0
			json.schedule do
				json.date followed.public_room.schedules.take.start.strftime('%d/%m')
				json.start followed.public_room.schedules.take.start.strftime('%H:%M')
			end
		end
	end
end