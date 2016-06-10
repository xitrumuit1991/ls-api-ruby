json.array! @videos do |picture|
	json.id 	picture.id
	json.video 	picture.video
	json.thumb 			picture.thumb_path[:thum]
	json.thum_w190h108 	picture.thumb_path[:thum_w190h108]
	json.thum_w380h216 	picture.thumb_path[:thum_w380h216]
	json.thum_w760h432 	picture.thumb_path[:thum_w760h432]
end