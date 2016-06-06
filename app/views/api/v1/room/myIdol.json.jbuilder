json.totalPage @totalPage
json.rooms @user_follow do |user_follow|
  room = user_follow.broadcaster.public_room
  json.id			room.id
  json.title		room.title
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

  sql_schedules = "select * from (SELECT rooms.id, schedules.room_id, schedules.start FROM rooms INNER JOIN schedules ON rooms.id = schedules.room_id WHERE rooms.is_privated = false and schedules.start > '#{Time.now}' and rooms.id='#{room.id}' ORDER BY schedules.start ASC) as schedule GROUP BY id ORDER BY -start desc"
  room_schedules = ActiveRecord::Base.connection.exec_query(sql_schedules)

  if room_schedules.present?
    start_time = room_schedules[0]["start"]
    json.date		start_time.strftime('%d/%m')
    json.start	start_time.strftime('%H:%M')
  else
    json.date		''
    json.start	''
  end

  json.broadcaster do
    json.id		user_follow.broadcaster.user.id
    json.bct_id		user_follow.broadcaster.id
    json.name	user_follow.broadcaster.user.name
    json.avatar	user_follow.broadcaster.user.avatar_path
    json.heart	user_follow.broadcaster.recived_heart
    json.exp	user_follow.broadcaster.broadcaster_exp
    json.level	user_follow.broadcaster.broadcaster_level.level
    json.isFollow		true
  end
end