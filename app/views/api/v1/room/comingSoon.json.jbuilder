json.totalPage @totalPage
json.rooms @room_schedules do |room|
  if room["start"] == nil || room["start"] < Time.now
    json.date ''
    json.start ''
  else
    json.date   room["start"].strftime('%d/%m')
    json.start  room["start"].strftime('%H:%M')
  end
  room = Room.find(room["id"])
  json.id			  room.id
  json.title		room.title
  json.slug		   room.slug

  json.thumb              replaceThumbCrop(room.id, room.thumb_path[:thumb] )
  json.thumb_mb           replaceThumbCrop(room.id, room.thumb_path[:thumb_w720h405] )
  json.thumb_w160h190     replaceThumbCrop(room.id, room.thumb_path[:thumb_w160h190] ) 
  json.thumb_w240h135     replaceThumbCrop(room.id, room.thumb_path[:thumb_w240h135] ) 
  json.thumb_w320h180     replaceThumbCrop(room.id, room.thumb_path[:thumb_w320h180] ) 
  json.thumb_w720h405     replaceThumbCrop(room.id, room.thumb_path[:thumb_w720h405] ) 
  json.thumb_w960h540     replaceThumbCrop(room.id, room.thumb_path[:thumb_w960h540] ) 

  json.thumb_poster               replaceThumbCrop(room.id, room.thumb_poster_path[:thumb] )
  json.thumb_poster_w360h640      replaceThumbCrop(room.id, room.thumb_poster_path[:thumb_w360h640] )
  json.thumb_poster_w720h1280     replaceThumbCrop(room.id, room.thumb_poster_path[:thumb_w720h1280] )
  json.thumb_poster_w1080h1920    replaceThumbCrop(room.id, room.thumb_poster_path[:thumb_w1080h1920] )

  json.broadcaster do
    json.id		room.broadcaster.user.id
    json.bct_id		room.broadcaster.id
    json.name	room.broadcaster.user.name
    json.avatar       room.broadcaster.user.avatar_path[:avatar]
    json.avatar_w60h60      room.broadcaster.user.avatar_path[:avatar_w60h60]
    json.avatar_w100h100    room.broadcaster.user.avatar_path[:avatar_w100h100]
    json.avatar_w120h120    room.broadcaster.user.avatar_path[:avatar_w120h120]
    json.avatar_w200h200    room.broadcaster.user.avatar_path[:avatar_w200h200]
    json.avatar_w240h240    room.broadcaster.user.avatar_path[:avatar_w240h240]
    json.avatar_w300h300    room.broadcaster.user.avatar_path[:avatar_w300h300]
    json.avatar_w400h400    room.broadcaster.user.avatar_path[:avatar_w400h400]
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