json.array! @schedules do |schedule|
	json.id		schedule.room.id
	json.title	schedule.room.title
	json.thumb	schedule.room.thumb
	json.broadcaster do
		json.id		schedule.room.broadcaster.user.id
		json.name	schedule.room.broadcaster.user.name
		json.heart	schedule.room.broadcaster.recived_heart
		json.exp	schedule.room.broadcaster.broadcaster_exp
		json.level	schedule.room.broadcaster.broadcaster_level.level
	end
end