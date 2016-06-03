json.array! @top_gift_users do |top_gift|
	json.id				top_gift.user.id
	json.name			top_gift.user.name
	json.avatar			top_gift.user.avatar_path
	json.level				top_gift.user.user_level.level
	json.quantity			top_gift.quantity
  json.total_money	top_gift.money
  json.avatar     		top_gift.user.avatar_path[:avatar]
  json.avatar_w60h60      top_gift.user.avatar_path[:avatar_w60h60]
  json.avatar_w100h100    top_gift.user.avatar_path[:avatar_w100h100]
  json.avatar_w120h120    top_gift.user.avatar_path[:avatar_w120h120]
  json.avatar_w200h200    top_gift.user.avatar_path[:avatar_w200h200]
  json.avatar_w240h240    top_gift.user.avatar_path[:avatar_w240h240]
  json.avatar_w300h300    top_gift.user.avatar_path[:avatar_w300h300]
  json.avatar_w400h400    top_gift.user.avatar_path[:avatar_w400h400]
end