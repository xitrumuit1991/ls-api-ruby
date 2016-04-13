json.array! @packages do |package|
	json.id				package.id
	json.vip			package.vip.name
	json.name			package.name
	json.code			package.code
	json.day			package.no_day
	json.price		package.price
	json.discount	package.discount
	json.details do
		json.image							"#{request.base_url}#{package.vip.image.url}"
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