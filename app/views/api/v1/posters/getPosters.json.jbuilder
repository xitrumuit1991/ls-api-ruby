json.array! @posters do |poster|
	json.id			poster.id
	json.title		poster.title
	json.sub_title	poster.sub_title
	json.link		poster.link
	json.thumb		"#{request.base_url}#{poster.thumb.other}"
end