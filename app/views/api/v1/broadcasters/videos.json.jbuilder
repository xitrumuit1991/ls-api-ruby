json.array! @videos do |picture|
	json.id 	picture.id
	json.video 	picture.video
	json.thumb 			picture.thumb_path[:thumb]
	json.thumb_w190h108 	picture.thumb_path[:thumb_w190h108]
	json.thumb_w380h216 	picture.thumb_path[:thumb_w380h216]
	json.thumb_w760h432 	picture.thumb_path[:thumb_w760h432]
end