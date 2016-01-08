if !@rusers_followed.present?
	json.array! @users_followed do |followed|
		json.id			followed.id
		json.name		followed.user.name
		json.username	followed.user.username
		json.avatar		"#{request.base_url}/api/v1/users/#{followed.user.id}/avatar"
		json.heart		followed.user.no_heart
		json.user_exp	followed.user.user_exp
		json.bct_exp	followed.broadcaster_exp
		json.level		followed.user.user_level.level
		json.room do
			json.id				followed.rooms.find_by_is_privated(false).id
			json.title		followed.rooms.find_by_is_privated(false).title
			json.slug			followed.rooms.find_by_is_privated(false).slug
			json.on_air		followed.rooms.find_by_is_privated(false).on_air
			json.thumb		"#{request.base_url}#{followed.rooms.find_by_is_privated(false).thumb.thumb}"
			json.thumb_mb	"#{request.base_url}#{followed.rooms.find_by_is_privated(false).thumb.thumb_mb}"
		end
		if !followed.rooms.find_by_is_privated(false).on_air and followed.rooms.find_by_is_privated(false).schedules.length > 0
			json.schedule do
				json.date followed.rooms.find_by_is_privated(false).schedules.take.start.strftime('%d/%m')
				json.start followed.rooms.find_by_is_privated(false).schedules.take.start.strftime('%H:%M')
			end
		end
	end
end