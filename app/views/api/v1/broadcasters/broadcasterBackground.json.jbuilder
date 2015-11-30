json.array! @images do |image|
	json.background		"#{request.base_url}#{image.image}"
end