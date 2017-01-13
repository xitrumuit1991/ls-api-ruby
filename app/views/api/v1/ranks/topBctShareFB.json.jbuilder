json.array! @topShareFb do |val|
	json.id					val.room.broadcaster.user.id
	json.name				val.room.broadcaster.user.name
	json.username			val.room.broadcaster.user.username
	json.avatar     		val.room.broadcaster.user.avatar_path[:avatar]
	json.avatar_w60h60      val.room.broadcaster.user.avatar_path[:avatar_w60h60]
	json.avatar_w100h100    val.room.broadcaster.user.avatar_path[:avatar_w100h100]
	json.avatar_w120h120    val.room.broadcaster.user.avatar_path[:avatar_w120h120]
	json.avatar_w200h200    val.room.broadcaster.user.avatar_path[:avatar_w200h200]
	json.avatar_w240h240    val.room.broadcaster.user.avatar_path[:avatar_w240h240]
	json.avatar_w300h300    val.room.broadcaster.user.avatar_path[:avatar_w300h300]
	json.avatar_w400h400    val.room.broadcaster.user.avatar_path[:avatar_w400h400]
	json.count				val.total_count
end