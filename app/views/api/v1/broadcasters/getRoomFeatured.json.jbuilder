json.array! @featured do |val|
	json.id			val.broadcaster.user.id
	json.name		val.broadcaster.user.name
	json.username	val.broadcaster.user.username
	json.avatar		"#{request.base_url}/api/v1/users/#{val.broadcaster.user.id}/avatar"
	json.heart		val.broadcaster.recived_heart
	json.bct_exp	val.broadcaster.broadcaster_exp
	json.level		val.broadcaster.broadcaster_level.level
end