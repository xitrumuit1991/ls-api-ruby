json.total_pages @total_pages
json.total_money @total_money
json.lounges @logs do |log|
	json.id							log.id
	json.index					log.lounge
	json.cost						log.cost
	json.created_at			log.created_at.strftime('%d/%m/%Y')
end