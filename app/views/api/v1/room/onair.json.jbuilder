json.array! @rooms do |room|
	json.id		room.id
	json.title	room.title
	json.thumb	room.thumb
	json.broadcaster do
		json.id		room.broadcaster.user.id
		json.name	room.broadcaster.user.name
		json.heart	room.broadcaster.recived_heart
		json.exp	room.broadcaster.broadcaster_exp
		json.level	room.broadcaster.broadcaster_level.level
	end
end