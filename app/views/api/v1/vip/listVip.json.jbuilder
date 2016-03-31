json.array! @vips do |vip|
	json.id						vip.id
	json.name					vip.name
	json.code					vip.code
	json.image				"#{request.base_url}#{vip.image}"
	if vip.priceVip(@day)
		json.money			vip.priceVip(@day).price
		json.package_id	vip.priceVip(@day).id
	else
		json.package_id	"Cập nhật"
		json.money			"Cập nhật"
	end
end