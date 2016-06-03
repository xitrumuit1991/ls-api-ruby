json.array! @top_broadcaster_level do |top_level|
	json.id					top_level.broadcaster.user.id
	json.name				top_level.broadcaster.user.name
	json.avatar     		top_level.broadcaster.user.avatar_path[:avatar]
	json.avatar_w60h60      top_level.broadcaster.user.avatar_path[:avatar_w60h60]
	json.avatar_w100h100    top_level.broadcaster.user.avatar_path[:avatar_w100h100]
	json.avatar_w120h120    top_level.broadcaster.user.avatar_path[:avatar_w120h120]
	json.avatar_w200h200    top_level.broadcaster.user.avatar_path[:avatar_w200h200]
	json.avatar_w240h240    top_level.broadcaster.user.avatar_path[:avatar_w240h240]
	json.avatar_w300h300    top_level.broadcaster.user.avatar_path[:avatar_w300h300]
	json.avatar_w400h400    top_level.broadcaster.user.avatar_path[:avatar_w400h400]
	json.heart				top_level.broadcaster.recived_heart
	json.bct_exp			top_level.broadcaster.broadcaster_exp
	json.level				top_level.broadcaster.broadcaster_level.level
	json.times				top_level.times
end