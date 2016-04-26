json.array! @bct_gifts do |bct_gift|
	json.id			bct_gift.gift.id
	json.name		bct_gift.gift.name
	json.image		"#{request.base_url}/#{bct_gift.gift.image.square}?timestamp=#{bct_gift.gift.updated_at.to_i}"
	json.price		bct_gift.gift.price
	json.discount	bct_gift.gift.discount
end