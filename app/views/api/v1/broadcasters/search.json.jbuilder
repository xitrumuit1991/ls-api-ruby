json.array! @bcts do |bct|
	json.id			bct.id
	json.name		bct.user.name
	json.username	bct.user.username
	json.avatar		bct.user.avatar_path
	json.heart		bct.user.no_heart
	json.user_exp	bct.user.user_exp
	if !bct.user.user_level.nil?
		json.level		bct.user.user_level.level
	end
	if bct.public_room.present?
		json.room do
			json.id				bct.public_room.id
			json.title		bct.public_room.title
			json.on_air		bct.public_room.on_air
			json.thumb		bct.public_room.thumb_path
			json.thumb_mb	bct.public_room.thumb_path(true)
		end
		if !bct.public_room.on_air and bct.public_room.schedules.length > 0
			json.schedule do
				json.date bct.public_room.schedules.last.start.strftime('%d/%m')
				json.start bct.public_room.schedules.last.start.strftime('%H:%M')
			end
		else
			json.schedules nil	
		end
	else
		json.room nil
		json.schedules nil
	end
end