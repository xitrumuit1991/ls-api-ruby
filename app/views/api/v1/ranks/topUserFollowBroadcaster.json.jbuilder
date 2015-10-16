json.array! @top_fans do |top_fans|
	json.id			top_fans.id
	json.name		top_fans.name
	json.username	top_fans.username
	json.avatar		"#{request.base_url}/api/v1/users/#{top_fans.id}/avatar"
	json.heart		top_fans.no_heart
	json.money		top_fans.money
	json.user_exp	top_fans.user_exp
	json.level		top_fans.user_level.level
end