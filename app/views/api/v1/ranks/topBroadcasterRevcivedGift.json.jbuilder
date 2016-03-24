json.array! @top_users do |top_user|
	json.id						top_user.user.id
	json.name					top_user.user.name
  json.username			top_user.user.username
	json.avatar				top_user.user.avatar_path
	json.quantity			top_user.quantity
	json.total_money	top_user.money
end