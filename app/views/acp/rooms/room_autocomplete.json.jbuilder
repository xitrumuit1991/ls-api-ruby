json.array! @rooms do |room|
	json.id				room.id
	json.name			room.title
end