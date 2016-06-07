json.totalPage @totalPage
json.rooms @user_follow do |user_follow|
  room = user_follow.broadcaster.public_room
  json.id			room.id
  json.title		room.title
  json.slug		room.slug
  json.thumb             room.thumb_path[:thumb]
  json.thumb_mb          room.thumb_path[:thumb_w720h405]
  json.thumb_w160h190    room.thumb_path[:thumb_w160h190]
  json.thumb_w240h135    room.thumb_path[:thumb_w240h135]
  json.thumb_w320h180    room.thumb_path[:thumb_w320h180]
  json.thumb_w720h405    room.thumb_path[:thumb_w720h405]
  json.thumb_w768h432    room.thumb_path[:thumb_w768h432]
  json.thumb_w960h540    room.thumb_path[:thumb_w960h540]
  json.on_air room.on_air
  json.broadcaster do
    json.id		user_follow.broadcaster.user.id
    json.bct_id		user_follow.broadcaster.id
    json.name	user_follow.broadcaster.user.name
    json.avatar     user_follow.broadcaster.user.avatar_path[:avatar]
    json.avatar_w60h60      user_follow.broadcaster.user.avatar_path[:avatar_w60h60]
    json.avatar_w100h100    user_follow.broadcaster.user.avatar_path[:avatar_w100h100]
    json.avatar_w120h120    user_follow.broadcaster.user.avatar_path[:avatar_w120h120]
    json.avatar_w200h200    user_follow.broadcaster.user.avatar_path[:avatar_w200h200]
    json.avatar_w240h240    user_follow.broadcaster.user.avatar_path[:avatar_w240h240]
    json.avatar_w300h300    user_follow.broadcaster.user.avatar_path[:avatar_w300h300]
    json.avatar_w400h400    user_follow.broadcaster.user.avatar_path[:avatar_w400h400]
    json.heart	user_follow.broadcaster.recived_heart
    json.exp	user_follow.broadcaster.broadcaster_exp
    json.level	user_follow.broadcaster.broadcaster_level.level
    json.isFollow		true
  end
end