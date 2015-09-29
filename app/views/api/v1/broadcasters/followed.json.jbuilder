json.array! @users_followed do |followed|
	json.id			followed.user.id
	json.name		followed.user.name
	json.username	followed.user.username
	json.avatar		"#{request.base_url}/api/v1/users/#{followed.user.id}/avatar"
	json.heart		followed.user.no_heart
	json.user_exp	followed.user.user_exp
	json.level		followed.user.user_level.level
end