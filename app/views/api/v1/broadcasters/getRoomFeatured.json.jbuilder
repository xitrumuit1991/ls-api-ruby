json.array! @featured do |val|
	json.id			val.broadcaster.user.id
	json.name		val.broadcaster.user.name
	json.username	val.broadcaster.user.username
	json.avatar		"#{request.base_url}/api/v1/users/#{val.broadcaster.user.id}/avatar"
	json.heart		val.broadcaster.recived_heart
	json.bct_exp	val.broadcaster.broadcaster_exp
	json.level		val.broadcaster.broadcaster_level.level

  json.room do
    json.id			val.broadcaster.rooms.find_by_is_privated(false).id
    json.title		val.broadcaster.rooms.find_by_is_privated(false).title
    json.on_air		val.broadcaster.rooms.find_by_is_privated(false).on_air
    json.slug		val.broadcaster.rooms.find_by_is_privated(false).slug
    json.thumb		"#{request.base_url}/api/v1/rooms/#{val.broadcaster.rooms.find_by_is_privated(false).id}/thumb"
    json.thumb_mb	 "#{request.base_url}/api/v1/rooms/#{val.broadcaster.rooms.find_by_is_privated(false).id}/thumb_mb"
    json.schedule do
      if val.broadcaster.rooms.find_by_is_privated(false).schedules.length > 0
        json.start  val.broadcaster.rooms.find_by_is_privated(false).schedules.take.start.strftime('%d/%m')
      else
        json.start  ''
      end
    end
  end
end