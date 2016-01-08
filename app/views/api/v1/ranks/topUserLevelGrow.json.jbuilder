json.array! @top_user_level do |top_level|
	json.id			top_level.user.id
	json.name		top_level.user.name
	json.avatar		"#{request.base_url}/api/v1/users/#{top_level.user.id}/avatar"
	json.heart		top_level.user.no_heart
	json.user_exp	top_level.user.user_exp
	json.level		top_level.user.user_level.level
	json.times		top_level.times
end