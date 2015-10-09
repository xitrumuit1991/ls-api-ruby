json.array! @top_heart do |top_heart|
	json.id			top_heart.broadcaster.user.id
	json.name		top_heart.broadcaster.user.name
	json.avatar		"#{request.base_url}/api/v1/users/#{top_heart.broadcaster.user.id}/avatar"
	json.heart		top_heart.quantity
	json.exp		top_heart.broadcaster.broadcaster_exp
	json.level		top_heart.broadcaster.broadcaster_level.level
	json.money		top_heart.broadcaster.user.money
end