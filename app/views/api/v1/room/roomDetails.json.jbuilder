json.title 				@room.title
json.slug 				@room.slug
json.thumb 				@room.thumb
json.background 		@room.background
json.is_privated 		@room.is_privated
json.broadcaster do
	json.id 			@room.broadcaster_id
	json.fullname		@room.broadcaster.fullname
end
json.room do
	json.id   			@room.room_type_id
	json.title			@room.room_type.title
	json.slug			@room.room_type.slug
	json.description	@room.room_type.description
end

