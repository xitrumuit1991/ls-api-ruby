json.array! @pictures do |picture|
	json.id			picture.id
	json.image 	"#{request.base_url}#{picture.image.url}"
	json.square "#{request.base_url}#{picture.image.square}"
end