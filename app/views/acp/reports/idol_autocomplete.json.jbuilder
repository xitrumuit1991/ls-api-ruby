json.array! @idols do |idol|
	json.id				idol.public_room.id
	json.name			idol.fullname
end