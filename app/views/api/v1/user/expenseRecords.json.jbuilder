json.array! @records do |gift|
	json.id			gift.id
	json.name		gift.name
	json.thumb				gift.thumb
	json.thumb_w50h50		gift.thumb_w50h50
	json.thumb_w100h100		gift.thumb_w100h100
	json.thumb_w200h200		gift.thumb_w200h200
	json.quantity	gift.quantity
	json.cost		gift.cost
	json.total_cost	gift.total_cost
	json.created_at	gift.created_at.strftime('%d/%m/%Y')
end