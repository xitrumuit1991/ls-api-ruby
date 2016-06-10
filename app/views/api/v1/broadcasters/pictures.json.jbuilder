json.array! @pictures do |picture|
	json.id			picture.id
	json.image 				picture.image_path[:image]
	json.image_w160h160 	picture.image_path[:image_w160h160]
	json.image_w320h320 	picture.image_path[:image_w320h320]
	json.image_w640h640 	picture.image_path[:image_w640h640]
end