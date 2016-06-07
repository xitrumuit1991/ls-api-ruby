json.totalPage @totalPage
json.rooms @myIdols do |item|
  room = Room.find(item.room_id)
  json.id			room.id
  json.title	room.title
  json.slug		room.slug
  json.thumb             room.thumb_path[:thumb]
  json.thumb_mb          room.thumb_path[:thumb_w960h540]
  json.thumb_w160h190    room.thumb_path[:thumb_w160h190]
  json.thumb_w240h135    room.thumb_path[:thumb_w240h135]
  json.thumb_w320h180    room.thumb_path[:thumb_w320h180]
  json.thumb_w720h405    room.thumb_path[:thumb_w720h405]
  json.thumb_w768h432    room.thumb_path[:thumb_w768h432]
  json.thumb_w960h540    room.thumb_path[:thumb_w960h540]
  json.on_air room.on_air

  if item.start != nil
    json.date		item.start.strftime('%d/%m')
    json.start	item.start.strftime('%H:%M')
  else
    json.date		''
    json.start	''
  end

  json.broadcaster do
    broadcaster = Broadcaster.find(item.bct_id)
    json.id		broadcaster.user.id
    json.bct_id		broadcaster.id
    json.name	broadcaster.user.name
    json.avatar	broadcaster.user.avatar_path
    json.heart	broadcaster.recived_heart
    json.exp	broadcaster.broadcaster_exp
    json.level	broadcaster.broadcaster_level.level
    json.isFollow		true
  end
end
