json.array! @rooms do |room|
	json.id			room.id
	json.title		room.title
	json.slug		room.slug
	json.thumb		room.thumb_path
	json.thumb_mb	room.thumb_path(true)
	json.broadcaster do
		json.id		room.broadcaster.user.id
		json.name	room.broadcaster.user.name
		json.avatar	room.broadcaster.user.avatar_path
		json.heart	room.broadcaster.recived_heart
		json.exp	room.broadcaster.broadcaster_exp
		json.level	room.broadcaster.broadcaster_level.level
	end
end