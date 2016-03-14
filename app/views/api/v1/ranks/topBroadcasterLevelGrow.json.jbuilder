json.array! @top_broadcaster_level do |top_level|
	json.id			top_level.broadcaster.user.id
	json.name		top_level.broadcaster.user.name
	json.avatar		top_level.broadcaster.user.avatar_path
	json.heart		top_level.broadcaster.recived_heart
	json.bct_exp	top_level.broadcaster.broadcaster_exp
	json.level		top_level.broadcaster.broadcaster_level.level
	json.times		top_level.times
end