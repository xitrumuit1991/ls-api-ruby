json.array! @vip_packages do |vip_package|
	json.id					vip_package.id
	json.name				vip_package.vip.name + ' - ' +vip_package.no_day + ' Ngày'
	json.code				vip_package.code
	json.image				"#{request.base_url}#{vip_package.vip.image}"
	json.money				number_with_delimiter(vip_package.price, delimiter: ".")
	json.day				vip_package.no_day
end