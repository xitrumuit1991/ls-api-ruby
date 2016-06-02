json.array! @packages do |package|
	json.id				package.id
	json.vip			package.vip.name
	json.name			package.name
	json.code			package.code
	json.day			package.no_day
	json.price		package.price
	json.discount	package.discount
	json.details do
		json.image             		package.vip.image_path[:image]
		json.image_w60h60         package.vip.image_path[:image_w60h60]
		json.image_w100h100       package.vip.image_path[:image_w100h100]
		json.image_w120h120       package.vip.image_path[:image_w120h120]
		json.image_w200h200       package.vip.image_path[:image_w200h200]
		json.image_w300h300       package.vip.image_path[:image_w300h300]
		json.image_w400h400       package.vip.image_path[:image_w400h400]
		json.weight							package.vip.weight
		json.no_char						package.vip.no_char
		json.screen_text_time		package.vip.screen_text_time
		json.screen_text_effect	package.vip.screen_text_effect
		json.kick_level					package.vip.kick_level
		json.clock_kick					package.vip.clock_kick
		json.clock_ads					package.vip.clock_ads
		json.exp_bonus					package.vip.exp_bonus
	end
end