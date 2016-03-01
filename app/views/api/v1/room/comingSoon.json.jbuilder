json.array! @schedules do |schedule|
	json.id			schedule.room.id
	json.title		schedule.room.title
	json.slug		schedule.room.slug
	json.thumb		"#{request.base_url}/api/v1/rooms/#{schedule.room.id}/thumb?timestamp=#{schedule.room.updated_at.to_time.to_i}"
	json.thumb_mb	"#{request.base_url}/api/v1/rooms/#{schedule.room.id}/thumb_mb?timestamp=#{schedule.room.updated_at.to_time.to_i}"
	json.date		schedule.start.strftime('%d/%m')
	json.start		schedule.start.strftime('%H:%M')
	json.broadcaster do
		json.id		schedule.room.broadcaster.user.id
		json.name	schedule.room.broadcaster.user.name
		json.avatar	"#{request.base_url}/api/v1/users/#{schedule.room.broadcaster.user.id}/avatar"
		json.heart	schedule.room.broadcaster.recived_heart
		json.exp	schedule.room.broadcaster.broadcaster_exp
		json.level	schedule.room.broadcaster.broadcaster_level.level
	end
end