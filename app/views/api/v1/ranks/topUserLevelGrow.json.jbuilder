json.array! @top_user_level do |top_level|
	json.id			top_level.id
	json.name		top_level.name
	json.avatar		"#{request.base_url}/api/v1/users/#{top_level.id}/avatar"
	json.heart		top_level.no_heart
	json.exp		top_level.user_exp
	json.level		top_level.user_level.level
end