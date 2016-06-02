json.array! @vips do |vip|
	json.id						vip.id
	json.name					vip.name
	json.code					vip.code
	json.image             		vip.image_path[:image]
	json.image_w60h60         vip.image_path[:image_w60h60]
	json.image_w100h100       vip.image_path[:image_w100h100]
	json.image_w120h120       vip.image_path[:image_w120h120]
	json.image_w200h200       vip.image_path[:image_w200h200]
	json.image_w300h300       vip.image_path[:image_w300h300]
	json.image_w400h400       vip.image_path[:image_w400h400]
	if vip.priceVip(@day)
		json.money		number_with_delimiter(vip.priceVip(@day).price, delimiter: ".")
		json.package_id	vip.priceVip(@day).id
		json.discount	vip.priceVip(@day).discount
		json.day		@day
	else
		json.package_id	"Cập nhật"
		json.money		"Cập nhật"
		json.discount	"Cập nhật"
		json.day		@day
	end
end