json.totalPage @totalPage
json.broadcasters @featured do |val|
	json.id			    val.broadcaster.user.id
	json.bct_id			val.broadcaster.id
	json.name		    val.broadcaster.user.name
	json.username	  val.broadcaster.user.username
	json.avatar		val.broadcaster.user.avatar_path
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
    json.totalUser	@totalUser[val.broadcaster.public_room.id]
    json.title		val.broadcaster.public_room.title
    json.slug		val.broadcaster.public_room.slug
    json.on_air		val.broadcaster.public_room.on_air
    json.thumb		val.broadcaster.public_room.thumb_path
    json.thumb_mb	val.broadcaster.public_room.thumb_path(true)
	end
end