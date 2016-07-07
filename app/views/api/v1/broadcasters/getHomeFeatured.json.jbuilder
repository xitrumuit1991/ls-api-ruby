json.broadcasters @featured do |val|
	json.room do
		json.id			val.broadcaster.public_room.id
    json.title	val.broadcaster.public_room.title
    json.slug		val.broadcaster.public_room.slug
    json.thumb             val.broadcaster.public_room.thumb_path[:thumb]
		json.thumb_mb          val.broadcaster.public_room.thumb_path[:thumb_w720h405]
		json.thumb_w160h190    val.broadcaster.public_room.thumb_path[:thumb_w160h190]
		json.thumb_w240h135    val.broadcaster.public_room.thumb_path[:thumb_w240h135]
		json.thumb_w320h180    val.broadcaster.public_room.thumb_path[:thumb_w320h180]
		json.thumb_w720h405    val.broadcaster.public_room.thumb_path[:thumb_w720h405]
		json.thumb_w768h432    val.broadcaster.public_room.thumb_path[:thumb_w768h432]
		json.thumb_w960h540    val.broadcaster.public_room.thumb_path[:thumb_w960h540]
	end
end