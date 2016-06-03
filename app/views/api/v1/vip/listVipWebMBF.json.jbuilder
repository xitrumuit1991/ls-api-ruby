json.array! @vip_packages do |vip_package|
	json.id					vip_package.id
	json.name				vip_package.vip.name + ' - ' +vip_package.no_day + ' Ngày'
	json.code				vip_package.code
	json.image             		vip_package.vip.image_path[:image]
	json.image_w60h60         vip_package.vip.image_path[:image_w60h60]
	json.image_w100h100       vip_package.vip.image_path[:image_w100h100]
	json.image_w120h120       vip_package.vip.image_path[:image_w120h120]
	json.image_w200h200       vip_package.vip.image_path[:image_w200h200]
	json.image_w300h300       vip_package.vip.image_path[:image_w300h300]
	json.image_w400h400       vip_package.vip.image_path[:image_w400h400]
	json.money				number_with_delimiter(vip_package.price, delimiter: ".")
	json.day				vip_package.no_day
end