json.array! @top_gift_users do |top_gift|
	json.id				top_gift.user.id
	json.name			top_gift.user.name
	json.avatar			"#{request.base_url}/api/v1/users/#{top_gift.user.id}/avatar"
	json.quantity		top_gift.quantity
	json.total_money	top_gift.total_money
end