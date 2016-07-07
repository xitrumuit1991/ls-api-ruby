json.array! @bct_actions do |bct_action|
	json.id			bct_action.room_action.id
	json.name		bct_action.room_action.name
	json.image					bct_action.room_action.image_path[:image_w100h100]
	json.image_w50h50		bct_action.room_action.image_path[:image_w50h50]
	json.image_w100h100	bct_action.room_action.image_path[:image_w100h100]
	json.image_w200h200	bct_action.room_action.image_path[:image_w200h200]
	json.price		bct_action.room_action.price
	json.max_vote	bct_action.room_action.max_vote
	json.voted		@status[bct_action.room_action.id].nil? ? 0 : @status[bct_action.room_action.id]
	json.percent	(@status[bct_action.room_action.id].nil? ? 0 : @status[bct_action.room_action.id]) * 100 / bct_action.room_action.max_vote
	json.discount	bct_action.room_action.discount
end