json.totalPage @totalPage
json.idols @data do |item|
  json.id			            item.broadcaster.id
  json.name	              item.broadcaster.user.name
  json.avatar             item.broadcaster.user.avatar_path[:avatar]
  json.avatar_w60h60      item.broadcaster.user.avatar_path[:avatar_w60h60]
  json.avatar_w100h100    item.broadcaster.user.avatar_path[:avatar_w100h100]
  json.avatar_w120h120    item.broadcaster.user.avatar_path[:avatar_w120h120]
  json.avatar_w200h200    item.broadcaster.user.avatar_path[:avatar_w200h200]
  json.avatar_w240h240    item.broadcaster.user.avatar_path[:avatar_w240h240]
  json.avatar_w300h300    item.broadcaster.user.avatar_path[:avatar_w300h300]
  json.avatar_w400h400    item.broadcaster.user.avatar_path[:avatar_w400h400]
  json.heart              item.broadcaster.recived_heart
  json.exp                item.broadcaster.broadcaster_exp
  json.level              item.broadcaster.broadcaster_level.level
  json.isFollow           true

  json.room do
    json.id               item.broadcaster.public_room.id
    json.title            item.broadcaster.public_room.title
    json.slug             item.broadcaster.public_room.slug
    json.thumb                      replaceThumbCrop(item.broadcaster.public_room.id, item.broadcaster.public_room.thumb_path[:thumb] ) 
    json.thumb_mb                   replaceThumbCrop(item.broadcaster.public_room.id, item.broadcaster.public_room.thumb_path[:thumb_mb] ) 
    json.thumb_w160h190             replaceThumbCrop(item.broadcaster.public_room.id, item.broadcaster.public_room.thumb_path[:thumb_w160h190] ) 
    json.thumb_w240h135             replaceThumbCrop(item.broadcaster.public_room.id, item.broadcaster.public_room.thumb_path[:thumb_w240h135] ) 
    json.thumb_w320h180             replaceThumbCrop(item.broadcaster.public_room.id, item.broadcaster.public_room.thumb_path[:thumb_w320h180] ) 
    json.thumb_w720h405             replaceThumbCrop(item.broadcaster.public_room.id, item.broadcaster.public_room.thumb_path[:thumb_w720h405] ) 
    json.thumb_w768h432             replaceThumbCrop(item.broadcaster.public_room.id, item.broadcaster.public_room.thumb_path[:thumb_w768h432] ) 
    json.thumb_w960h540             replaceThumbCrop(item.broadcaster.public_room.id, item.broadcaster.public_room.thumb_path[:thumb_w960h540] ) 


    json.on_air           item.broadcaster.public_room.on_air

    json.schedule do
      if item.start.nil?
        json.date   ''
        json.start  ''
      else
        json.date   item.start.strftime('%d/%m')
        json.start  item.start.strftime('%H:%M')
      end
    end
  end
end