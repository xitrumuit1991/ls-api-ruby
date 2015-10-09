json.array! @top_heart do |top_heart|
	json.id			top_heart.user.id
	json.name		top_heart.user.name
	json.avatar		"#{request.base_url}/api/v1/users/#{top_heart.user.id}/avatar"
	json.heart		top_heart.recived_heart
	json.exp		top_heart.broadcaster_exp
	json.level		top_heart.broadcaster_level.level
end