json.array! @coins do |coin|
	json.id			coin.id
	json.name		coin.name
	json.code		coin.code
	json.price		coin.price
	json.quantity	coin.quantity
end