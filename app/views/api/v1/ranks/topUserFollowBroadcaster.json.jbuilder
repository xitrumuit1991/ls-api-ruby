json.array! @top_fans do |top_fans|
	json.id					top_fans.id
	json.name				top_fans.name
	json.username			top_fans.username
	json.avatar     		top_fans.user.avatar_path[:avatar]
	json.avatar_w60h60      top_fans.user.avatar_path[:avatar_w60h60]
	json.avatar_w100h100    top_fans.user.avatar_path[:avatar_w100h100]
	json.avatar_w120h120    top_fans.user.avatar_path[:avatar_w120h120]
	json.avatar_w200h200    top_fans.user.avatar_path[:avatar_w200h200]
	json.avatar_w240h240    top_fans.user.avatar_path[:avatar_w240h240]
	json.avatar_w300h300    top_fans.user.avatar_path[:avatar_w300h300]
	json.avatar_w400h400    top_fans.user.avatar_path[:avatar_w400h400]
	json.heart				top_fans.no_heart
	json.money				top_fans.money
	json.user_exp			top_fans.user_exp
	json.level				top_fans.user_level.level
end