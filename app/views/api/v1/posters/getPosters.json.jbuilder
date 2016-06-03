json.array! @posters do |poster|
	json.id			poster.id
	json.title		poster.title
	json.sub_title	poster.sub_title
	json.link		poster.link
	json.thumb		"#{request.base_url}#{poster.thumb.other}"
	json.thumb 				poster.thumb_path[:thum]
	json.thumb_w180h480 	poster.thumb_path[:thumb_w180h480]
	json.thumb_w360h960 	poster.thumb_path[:thumb_w360h960]
end