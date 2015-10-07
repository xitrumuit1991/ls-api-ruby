json.array! @top_gift_broadcasters do |top_gift|
	json.id				top_gift.room.broadcaster.user.id
	json.name			top_gift.room.broadcaster.user.name
	json.avatar			"#{request.base_url}/api/v1/users/#{top_gift.room.broadcaster.user.id}/avatar"
	json.total_money	top_gift.total_money
	json.quantity		top_gift.quantity
end