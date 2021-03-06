json.array! @featured do |val|
	json.id					val.broadcaster.user.id
	json.name				val.broadcaster.user.name
	json.username			val.broadcaster.user.username
	json.avatar				val.broadcaster.user.avatar_path
	json.avatar     		val.broadcaster.user.avatar_path[:avatar]
	json.avatar_w60h60      val.broadcaster.user.avatar_path[:avatar_w60h60]
	json.avatar_w100h100    val.broadcaster.user.avatar_path[:avatar_w100h100]
	json.avatar_w120h120    val.broadcaster.user.avatar_path[:avatar_w120h120]
	json.avatar_w200h200    val.broadcaster.user.avatar_path[:avatar_w200h200]
	json.avatar_w240h240    val.broadcaster.user.avatar_path[:avatar_w240h240]
	json.avatar_w300h300    val.broadcaster.user.avatar_path[:avatar_w300h300]
	json.avatar_w400h400    val.broadcaster.user.avatar_path[:avatar_w400h400]
	json.heart				val.broadcaster.recived_heart
	json.bct_exp			val.broadcaster.broadcaster_exp
	json.level				val.broadcaster.broadcaster_level.level
end