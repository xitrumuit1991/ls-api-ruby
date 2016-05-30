json.totalPage @totalPage
json.rooms @user_follow do |user_follow|
  room = user_follow.broadcaster.public_room
  json.id			room.id
  json.title		room.title
  json.slug		room.slug
  json.thumb		room.thumb_path
  json.thumb_mb	room.thumb_path(true)
  json.on_air room.on_air
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