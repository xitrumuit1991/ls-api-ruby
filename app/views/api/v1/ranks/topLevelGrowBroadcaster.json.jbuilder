json.array! @top_broadcaster_level do |top_level|
	json.id			top_level.user.id
	json.name		top_level.user.name
	json.avatar		"#{request.base_url}/api/v1/users/#{top_level.user.id}/avatar"
	json.heart		top_level.recived_heart
	json.exp		top_level.broadcaster_exp
	json.level		top_level.broadcaster_level.level
end