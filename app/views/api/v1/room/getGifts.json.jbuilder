json.array! @gifts do |gift|
	json.id			gift.id
	json.name		gift.name
	json.image		"#{request.base_url}/#{gift.image.square}"
	json.price		gift.price
	json.discount	gift.discount
end