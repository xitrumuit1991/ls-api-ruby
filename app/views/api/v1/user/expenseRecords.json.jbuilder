json.records @records do |gift|
	json.id			gift.id
	json.name		gift.gift.name
	json.thumb		"#{request.base_url}#{gift.gift.image_url}"
	json.quantity	gift.quantity
	json.cost		gift.cost
	json.total_cost	(gift.cost*gift.quantity)
	json.created_at	gift.created_at.strftime('%d/%m/%Y')
end