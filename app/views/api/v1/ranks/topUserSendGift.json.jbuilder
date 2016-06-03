json.array! @top_gift_users do |top_gift|
	json.id				top_gift.user.id
	json.name			top_gift.user.name
	json.avatar			top_gift.user.avatar_path
	json.quantity		top_gift.quantity
	json.total_money	top_gift.money
end