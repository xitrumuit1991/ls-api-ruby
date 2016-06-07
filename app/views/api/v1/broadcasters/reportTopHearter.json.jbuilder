json.total @total
json.users @data do |item|
	json.name		item.user.name
	json.avatar     item.user.avatar_path[:avatar]
    json.avatar_w60h60      item.user.avatar_path[:avatar_w60h60]
    json.avatar_w100h100    item.user.avatar_path[:avatar_w100h100]
    json.avatar_w120h120    item.user.avatar_path[:avatar_w120h120]
    json.avatar_w200h200    item.user.avatar_path[:avatar_w200h200]
    json.avatar_w240h240    item.user.avatar_path[:avatar_w240h240]
    json.avatar_w300h300    item.user.avatar_path[:avatar_w300h300]
    json.avatar_w400h400    item.user.avatar_path[:avatar_w400h400]
	json.vip		item.user.vip
	json.hearts	item.quantity
end