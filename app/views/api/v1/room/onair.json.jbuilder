json.totalPage @totalPage
json.rooms @rooms do |room|
	json.id			room.id
	json.title		room.title
	json.slug		room.slug
	json.thumb		"#{request.base_url}/api/v1/rooms/#{room.id}/thumb"
	json.thumb_mb	"#{request.base_url}/api/v1/rooms/#{room.id}/thumb_mb"
	json.broadcaster do
		json.id		room.broadcaster.id
		json.name	room.broadcaster.user.name
		json.avatar	"#{request.base_url}/api/v1/users/#{room.broadcaster.user.id}/avatar"
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