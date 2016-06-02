json.total @total
json.users @data do |item|
	json.name		item.user.name
	json.avatar	item.user.avatar_path
	json.vip		item.user.vip
	json.money	item.total
end