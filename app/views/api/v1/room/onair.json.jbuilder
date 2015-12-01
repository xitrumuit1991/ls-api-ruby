json.array! @rooms do |room|
	json.id			room.id
	json.title		room.title
	json.thumb		"#{request.base_url}#{room.thumb.thumb}"
	json.thumb_mb	"#{request.base_url}#{room.thumb.thumb_mb.url}"
	json.broadcaster do
		json.id		room.broadcaster.user.id
		json.name	room.broadcaster.user.name
		json.avatar	"#{request.base_url}/api/v1/users/#{room.broadcaster.user.id}/avatar"
		json.heart	room.broadcaster.recived_heart
		json.exp	room.broadcaster.broadcaster_exp
		json.level	room.broadcaster.broadcaster_level.level
	end
end