json.array! @gifts do |gift|
	json.id			gift.id
	json.name		gift.name
	json.image		gift.image.url
	json.price		gift.price
	json.discount	gift.discount
end