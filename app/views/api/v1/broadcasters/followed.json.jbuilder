json.array! @users_followed do |followed|
	json.id			followed.user.id
	json.name		followed.user.name
	json.username	followed.user.username
	json.avatar		"#{request.base_url}/api/v1/users/#{followed.user.id}/avatar"
	json.heart		followed.user.no_heart
	json.user_exp	followed.user.user_exp
	json.level		followed.user.user_level.level
	json.room_id	followed.rooms.find_by_is_privated(false).id
	json.onair		followed.rooms.find_by_is_privated(false).on_air
	if !followed.rooms.find_by_is_privated(false).on_air and followed.rooms.find_by_is_privated(false).schedules.length > 0
		json.schedule do
			json.date followed.rooms.find_by_is_privated(false).schedules.take.start.strftime('%d/%m')
			json.start followed.rooms.find_by_is_privated(false).schedules.take.start.strftime('%H:%M')
		end
	end
end