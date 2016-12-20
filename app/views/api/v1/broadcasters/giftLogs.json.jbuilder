json.total_pages @total_pages
json.total_money @total_money
json.gifts @logs do |log|
	json.id							log.id
	json.name						log.gift.name
	json.thumb					log.gift.image_path[:image]
	json.thumb_w50h50		log.gift.image_path[:image_w50h50]
	json.thumb_w100h100	log.gift.image_path[:image_w100h100]
	json.thumb_w200h200	log.gift.image_path[:image_w200h200]
	json.quantity				log.quantity
	json.cost						log.gift.price
	json.total					log.cost
	json.created_at			log.created_at.strftime('%d/%m/%Y')
end