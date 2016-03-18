json.array! @top_gift_broadcasters do |top_gift_broadcaster|
	json.id				top_gift_broadcaster.broadcaster.user.id
	json.name			top_gift_broadcaster.broadcaster.user.name
  json.username	top_gift_broadcaster.broadcaster.user.username
	json.avatar			top_gift_broadcaster.broadcaster.user.avatar_path
	json.quantity		top_gift_broadcaster.quantity
	json.total_money	top_gift_broadcaster.total_money
end