json.array! @actions do |action|
	json.id			action.id
	json.name		action.name
	json.image		"#{request.base_url}/#{action.image.square}"
	json.price		action.price
	json.max_vote	action.max_vote
	json.voted		@status[action.id].nil? ? 0 : @status[action.id]
	json.percent	(@status[action.id].nil? ? 0 : @status[action.id]) * 100 / action.max_vote
	json.discount	action.discount
end