json.totalPage @totalPage
json.rooms @rooms do |room|
	json.id			room.id
	json.title		room.title
	json.slug		room.slug
	json.slug		room.slug
	json.totalUser		@totalUser[room.id]
	json.thumb             room.thumb_path[:thumb]
	json.thumb_mb          room.thumb_path[:thumb_w960h540]
	json.thumb_w160h190    room.thumb_path[:thumb_w160h190]
	json.thumb_w240h135    room.thumb_path[:thumb_w240h135]
	json.thumb_w320h180    room.thumb_path[:thumb_w320h180]
	json.thumb_w720h405    room.thumb_path[:thumb_w720h405]
	json.thumb_w768h432    room.thumb_path[:thumb_w768h432]
	json.thumb_w960h540    room.thumb_path[:thumb_w960h540]
	json.broadcaster do
		json.id		room.broadcaster.user.id
		json.bct_id		room.broadcaster.id
		json.name	room.broadcaster.user.name
		json.avatar	room.broadcaster.user.avatar_path
		json.heart	room.broadcaster.recived_heart
		json.exp	room.broadcaster.broadcaster_exp
		json.level	room.broadcaster.broadcaster_level.level

    if @user != nil
      json.isFollow		!@user.broadcasters.where(id: room.broadcaster.id).empty?
    else
      json.isFollow		false
    end
	end
end