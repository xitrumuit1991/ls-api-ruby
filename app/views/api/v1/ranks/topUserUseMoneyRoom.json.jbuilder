json.array! @top_users do |top_user|
	json.id				top_user.user.id
	json.name			top_user.user.name
	json.level			top_user.user.user_level.level
	json.avatar			"#{request.base_url}/api/v1/users/#{top_user.user.id}/avatar"
	json.money			top_user.money
end