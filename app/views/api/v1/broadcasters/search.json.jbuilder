json.array! @users do |user|
	json.id			user.id
	json.name		user.name
	json.username	user.username
	json.avatar		"#{request.base_url}/api/v1/users/#{user.id}/avatar"
	json.heart		user.no_heart
	json.user_exp	user.user_exp
	json.level		user.user_level.level
	if !user.public_room.nil?
		json.room do
			json.id			user.public_room.id
			json.title		user.public_room.title
			json.on_air		user.public_room.on_air
			json.thumb		"#{request.base_url}#{user.public_room.thumb.thumb}"
			json.thumb_mb	"#{request.base_url}#{user.public_room.thumb.thumb_mb}"
		end	
		if !user.public_room.on_air and user.public_room.schedules.length > 0
			json.schedules do
				json.date user.public_room.schedules.take.start.strftime('%d/%m')
				json.start user.public_room.schedules.take.start.strftime('%H:%M')
			end
		end
	end
end