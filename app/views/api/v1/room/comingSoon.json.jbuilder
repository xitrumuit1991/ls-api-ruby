json.array! @schedules do |schedule|
	json.id		schedule.room.id
	json.title	schedule.room.title
	json.thumb	"#{request.base_url}#{schedule.room.thumb.url}"
	json.date	schedule.date.strftime('%d/%m')
	json.start	schedule.start
	json.broadcaster do
		json.id		schedule.room.broadcaster.user.id
		json.name	schedule.room.broadcaster.user.name
		json.avatar	"#{request.base_url}/api/v1/users/#{schedule.room.broadcaster.user.id}/avatar"
		json.heart	schedule.room.broadcaster.recived_heart
		json.exp	schedule.room.broadcaster.broadcaster_exp
		json.level	schedule.room.broadcaster.broadcaster_level.level
	end
end