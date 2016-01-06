json.array! @featured do |val|
	json.id			val.broadcaster.user.id
	json.name		val.broadcaster.user.name
	json.username	val.broadcaster.user.username
	json.avatar		"#{request.base_url}/api/v1/users/#{val.broadcaster.user.id}/avatar"
	json.heart		val.broadcaster.recived_heart
	json.bct_exp	val.broadcaster.broadcaster_exp
	json.level		val.broadcaster.broadcaster_level.level
	json.room do
		json.id			val.broadcaster.rooms.find_by_is_privated(false).id
		json.title		val.broadcaster.rooms.find_by_is_privated(false).title
		json.slug		val.broadcaster.rooms.find_by_is_privated(false).slug
		json.on_air		val.broadcaster.rooms.find_by_is_privated(false).on_air
		json.thumb		"#{request.base_url}/api/v1/rooms/#{val.broadcaster.rooms.find_by_is_privated(false).id}/thumb"
		json.thumb_mb	"#{request.base_url}/api/v1/rooms/#{val.broadcaster.rooms.find_by_is_privated(false).id}/thumb_mb"
	end
end