json.array! @room_types do |room_type|
	json.id				room_type.id
	json.title			room_type.title
	json.slug			room_type.slug
	json.description	room_type.description
end