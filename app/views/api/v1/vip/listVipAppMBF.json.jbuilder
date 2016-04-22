json.array! @vip do |vip|
	if @mode == 0
		json.name 				vip.name
		json.image				"#{request.base_url}#{vip.image}"
		json.no_char			vip.no_char
		json.screen_text_time	vip.screen_text_time
		json.screen_text_effect	vip.screen_text_effect
		json.kick_level			vip.kick_level = 0 ? 'Kick User phổ thông' : 'Kich Vip'+vip.kick_level+' trở Xuống'
		if vip.clock_kick == 0
			json.clock_kick 	0
		elsif vip.clock_kick == 1
			json.clock_kick 	"Kick bởi room owner"
		else
			json.clock_kick 	"Không bị kick"
		end
		json.exp_bonus				vip.exp_bonus
		json.vip_packages vip.vip_packages.where('name IS NOT NULL') do |vip_pkg|
			json.id				vip_pkg.id
			json.code 			vip_pkg.code
			json.no_day			vip_pkg.no_day
			json.price			vip_pkg.price
			json.discount		vip_pkg.discount
		end
	else
		json.name 				vip.vip.name
		json.code 				vip.code
		json.image				"#{request.base_url}#{vip.vip.image}"
		json.no_char			vip.vip.no_char
		json.screen_text_time	vip.vip.screen_text_time
		json.screen_text_effect	vip.vip.screen_text_effect
		json.kick_level			vip.vip.kick_level = 0 ? 'Kick User phổ thông' : 'Kich Vip'+vip.vip.kick_level+' trở Xuống'
		if vip.vip.clock_kick == 0
			json.clock_kick 	0
		elsif vip.vip.clock_kick == 1
			json.clock_kick 	"Kick bởi room owner"
		else
			json.clock_kick 	"Không bị kick"
		end
		json.exp_bonus				vip.vip.exp_bonus
		json.vip_id				vip.id
		json.no_day			vip.no_day
		json.price			vip.price
		json.discount		vip.discount
	end
end