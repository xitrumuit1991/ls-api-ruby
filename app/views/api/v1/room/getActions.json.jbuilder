json.array! @actions do |action|
	json.id			action.id
	json.name		action.name
	json.image		"#{request.base_url}/#{action.image.url}"
	json.price		action.price
	json.max_vote	action.max_vote
	json.discount	action.discount
end