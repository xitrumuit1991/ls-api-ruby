json.array! @bct_gifts do |bct_gift|
	json.id				bct_gift.gift.id
	json.name			bct_gift.gift.name
	json.image			bct_gift.gift.image_path[:image]
	json.image_w50h50	bct_gift.gift.image_path[:image_w50h50]
	json.image_w100h100	bct_gift.gift.image_path[:image_w100h100]
	json.image_w200h200	bct_gift.gift.image_path[:image_w200h200]
	json.price			bct_gift.gift.price
	json.discount		bct_gift.gift.discount
end