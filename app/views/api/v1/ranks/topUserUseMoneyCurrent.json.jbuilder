json.array! @top_users do |top_user|
	json.id					top_user.user.id
	json.name				top_user.user.name
	json.level				top_user.user.user_level.level
	json.avatar     		top_user.user.avatar_path[:avatar]
	json.avatar_w60h60      top_user.user.avatar_path[:avatar_w60h60]
	json.avatar_w100h100    top_user.user.avatar_path[:avatar_w100h100]
	json.avatar_w120h120    top_user.user.avatar_path[:avatar_w120h120]
	json.avatar_w200h200    top_user.user.avatar_path[:avatar_w200h200]
	json.avatar_w240h240    top_user.user.avatar_path[:avatar_w240h240]
	json.avatar_w300h300    top_user.user.avatar_path[:avatar_w300h300]
	json.avatar_w400h400    top_user.user.avatar_path[:avatar_w400h400]
	json.money				top_user.money
	json.vip 				top_user.user.checkVip == 1 ? top_user.user.user_has_vip_packages.find_by_actived(true).vip_package.vip.weight : 0
end