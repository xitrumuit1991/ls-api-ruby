json.array! @bcts do |bct|
	json.id			bct.id
	json.name		bct.user.name
	json.username	bct.user.username
	json.avatar		"#{request.base_url}/api/v1/users/#{bct.user_id}/avatar"
	json.heart		bct.user.no_heart
	json.user_exp	bct.user.user_exp
	if !bct.user.user_level.nil?
		json.level		bct.user.user_level.level
	end
	if !bct.user.public_room.nil?
		json.room do
			json.id			bct.user.public_room.id
			json.title		bct.user.public_room.title
			json.on_air		bct.user.public_room.on_air
			json.thumb		"#{request.base_url}#{bct.user.public_room.thumb.thumb}"
			json.thumb_mb	"#{request.base_url}#{bct.user.public_room.thumb.thumb_mb}"
		end
		if !bct.user.public_room.on_air and bct.user.public_room.schedules.length > 0
			json.schedules bct.rooms.find_by_is_privated(false).schedules do |schedule|
				json.date	schedule.start.strftime('%d/%m')
				json.start	schedule.start.strftime('%H:%M')
			end
		else
			json.schedules nil	
		end
	else
		json.room nil
		json.schedules nil
	end
end