json.array! @videos do |picture|
	json.id 	picture.id
	json.video 	picture.video
	if picture.thumb?
		json.thumb "#{request.base_url}#{picture.thumb.thumb}"
	else
		json.thumb nil
	end
end