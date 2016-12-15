json.total_pages @total_pages
json.total_money @total_money
json.actions @logs do |log|
	json.id							log.id
	json.name						log.room_action.name
	json.thumb					log.room_action.image_path[:image]
	json.thumb_w50h50		log.room_action.image_path[:image_w50h50]
	json.thumb_w100h100	log.room_action.image_path[:image_w100h100]
	json.thumb_w200h200	log.room_action.image_path[:image_w200h200]
	json.quantity				1
	json.cost						log.cost
	json.total					log.cost
	json.created_at			log.created_at.strftime('%d/%m/%Y')
end