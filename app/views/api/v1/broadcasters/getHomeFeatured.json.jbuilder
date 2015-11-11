json.array! @featured do |val|
	json.id			val.broadcaster.user.id
	json.name		val.broadcaster.user.name
	json.avatar		"#{request.base_url}/api/v1/users/#{val.broadcaster.user.id}/avatar"
	json.heart		val.broadcaster.recived_heart
	json.user_exp	val.broadcaster.broadcaster_exp
	json.level		val.broadcaster.broadcaster_level.level
	json.room do
		json.id			val.broadcaster.rooms.find_by_is_privated(false).id
		json.name		val.broadcaster.rooms.find_by_is_privated(false).title
		json.on_air		val.broadcaster.rooms.find_by_is_privated(false).on_air
		json.thumb		"#{request.base_url}#{val.broadcaster.rooms.find_by_is_privated(false).thumb.thumb}"
		json.thumb_mb	"#{request.base_url}#{val.broadcaster.rooms.find_by_is_privated(false).thumb.thumb_mb}"
	end

	json.schedules val.broadcaster.rooms.find_by_is_privated(false).schedules do |schedule|
		json.date	schedule.start.strftime('%d/%m')
		json.start	schedule.start.strftime('%H:%M')
	end
end