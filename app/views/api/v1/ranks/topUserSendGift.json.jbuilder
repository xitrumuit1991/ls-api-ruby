json.array! @top_gift_users do |top_gift|
	json.id				top_gift.broadcaster.user.id
	json.name			top_gift.broadcaster.user.name
	json.avatar			"#{request.base_url}/api/v1/users/#{top_gift.broadcaster.user.id}/avatar"
	json.quantity		top_gift.quantity
	json.total_money	top_gift.total_money
end