json.array! @vips do |vip|
	json.id					vip.id
	json.name				vip.name
	json.code				vip.code
	json.image			"#{request.base_url}#{vip.image}"
	json.money			vip.priceVip(@day)
end