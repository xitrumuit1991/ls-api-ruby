json.array! @top_heart do |top_heart|
	json.broadcaster_id		top_heart.broadcaster.user.id
	json.name							top_heart.broadcaster.user.name
	json.username					top_heart.broadcaster.user.username
	json.avatar						top_heart.broadcaster.user.avatar_path
	json.heart						top_heart.quantity
	json.bct_exp					top_heart.broadcaster.broadcaster_exp
	json.level						top_heart.broadcaster.broadcaster_level.level
	json.money						top_heart.broadcaster.user.money
end