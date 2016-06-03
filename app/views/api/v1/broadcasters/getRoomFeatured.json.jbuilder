json.array! @featured do |val|
	json.id			val.broadcaster.user.id
	json.bct_id		val.broadcaster.id
	json.name		val.broadcaster.user.name
	json.username	val.broadcaster.user.username
  json.avatar             val.broadcaster.user.avatar_path[:avatar]
  json.avatar_w60h60      val.broadcaster.user.avatar_path[:avatar_w60h60]
  json.avatar_w100h100    val.broadcaster.user.avatar_path[:avatar_w100h100]
  json.avatar_w120h120    val.broadcaster.user.avatar_path[:avatar_w120h120]
  json.avatar_w200h200    val.broadcaster.user.avatar_path[:avatar_w200h200]
  json.avatar_w240h240    val.broadcaster.user.avatar_path[:avatar_w240h240]
  json.avatar_w300h300    val.broadcaster.user.avatar_path[:avatar_w300h300]
  json.avatar_w400h400    val.broadcaster.user.avatar_path[:avatar_w400h400]
	json.heart		val.broadcaster.recived_heart
	json.bct_exp	val.broadcaster.broadcaster_exp
	json.level		val.broadcaster.broadcaster_level.level
  if @user != nil
    json.isFollow		!@user.broadcasters.where(id: val.broadcaster.id).empty?
  else
    json.isFollow		false
  end
  json.room do
    json.id			val.broadcaster.public_room.id
    json.title		val.broadcaster.public_room.title
    json.on_air		val.broadcaster.public_room.on_air
    json.totalUser		@totalUser[val.broadcaster.public_room.id]
    json.slug		val.broadcaster.public_room.slug
    json.thumb             val.broadcaster.public_room.thumb_path[:thumb]
    json.thumb_mb          val.broadcaster.public_room.thumb_path[:thumb_w960h540]
    json.thumb_w160h190    val.broadcaster.public_room.thumb_path[:thumb_w160h190]
    json.thumb_w240h135    val.broadcaster.public_room.thumb_path[:thumb_w240h135]
    json.thumb_w320h180    val.broadcaster.public_room.thumb_path[:thumb_w320h180]
    json.thumb_w720h405    val.broadcaster.public_room.thumb_path[:thumb_w720h405]
    json.thumb_w768h432    val.broadcaster.public_room.thumb_path[:thumb_w768h432]
    json.thumb_w960h540    val.broadcaster.public_room.thumb_path[:thumb_w960h540]
    json.schedule do
      if val.broadcaster.public_room.schedules.length > 0
        json.start  val.broadcaster.public_room.schedules.last.start.strftime('%d/%m')
      else
        json.start  ''
      end
    end
  end
end