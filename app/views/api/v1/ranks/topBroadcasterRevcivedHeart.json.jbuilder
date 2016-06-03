json.array! @top_heart do |top_heart|
	json.broadcaster_id		top_heart.broadcaster.user.id
	json.name						top_heart.broadcaster.user.name
	json.username					top_heart.broadcaster.user.username
	json.avatar     				top_heart.broadcaster.user.avatar_path[:avatar]
	json.avatar_w60h60      		top_heart.broadcaster.user.avatar_path[:avatar_w60h60]
	json.avatar_w100h100    		top_heart.broadcaster.user.avatar_path[:avatar_w100h100]
	json.avatar_w120h120    		top_heart.broadcaster.user.avatar_path[:avatar_w120h120]
	json.avatar_w200h200    		top_heart.broadcaster.user.avatar_path[:avatar_w200h200]
	json.avatar_w240h240    		top_heart.broadcaster.user.avatar_path[:avatar_w240h240]
	json.avatar_w300h300    		top_heart.broadcaster.user.avatar_path[:avatar_w300h300]
	json.avatar_w400h400    		top_heart.broadcaster.user.avatar_path[:avatar_w400h400]
	json.heart						top_heart.quantity
	json.bct_exp					top_heart.broadcaster.broadcaster_exp
	json.level						top_heart.broadcaster.broadcaster_level.level
	json.money						top_heart.broadcaster.user.money
end