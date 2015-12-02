json.array! @records do |gift|
	json.id			gift.id
	json.name		gift.name
	json.thumb		gift.thumb.square
	json.quantity	gift.quantity
	json.cost		gift.cost
	json.total_cost	gift.total_cost
	json.created_at	gift.created_at.strftime('%d/%m/%Y')
end