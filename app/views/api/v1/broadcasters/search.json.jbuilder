json.array! @users do |user|
	json.id			user.id
	json.name		user.name
	json.username	user.username
	json.avatar		"#{request.base_url}/api/v1/users/#{user.id}/avatar"
	json.heart		user.no_heart
	json.user_exp	user.user_exp
	json.level		user.user_level.level
	json.room_id	user.broadcaster.rooms.find_by_is_privated(false).id
	json.onair		user.broadcaster.rooms.find_by_is_privated(false).on_air
	if !user.broadcaster.rooms.find_by_is_privated(false).on_air and user.broadcaster.rooms.find_by_is_privated(false).schedules.length > 0
		json.schedule do
			json.date user.broadcaster.rooms.find_by_is_privated(false).schedules.take.start.strftime('%d/%m')
			json.start user.broadcaster.rooms.find_by_is_privated(false).schedules.take.start.strftime('%H:%M')
		end
	end
end