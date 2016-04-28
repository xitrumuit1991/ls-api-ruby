json.array! @coins do |coin|
	json.id							coin.id
	json.name						coin.name
	json.code						coin.code
	json.price					coin.price
	json.price_usd			coin.price_usd
	json.quantity				coin.quantity
	json.bonus_coins		coin.bonus_coins
	json.bonus_percent	coin.bonus_percent
end