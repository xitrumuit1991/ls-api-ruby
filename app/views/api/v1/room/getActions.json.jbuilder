json.array! @actions do |action|
	json.id			action.id
	json.name		action.name
	json.image		action.image.url
	json.price		action.price
	json.discount	action.discount
end