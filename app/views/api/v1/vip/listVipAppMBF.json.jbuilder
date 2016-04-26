json.array! @vip do |vip|
	if @mode == 0
		json.details do
			json.name 				vip.name
			json.image				"#{request.base_url}#{vip.image}"
			json.no_char			vip.no_char
			json.screen_text_time	vip.screen_text_time
			json.screen_text_effect	vip.screen_text_effect
			json.kick_level			vip.kick_level = 0 ? 'Kick User phổ thông' : 'Kich Vip'+vip.kick_level+' trở Xuống'
			if vip.clock_kick == 0
				json.clock_kick 	nil
			elsif vip.clock_kick == 1
				json.clock_kick 	"Kick bởi room owner"
			else
				json.clock_kick 	"Không bị kick"
			end
			json.exp_bonus				vip.exp_bonus
			json.clock_ads				vip.clock_ads
		end
		json.vip_packages vip.vip_packages.where('code != "VIP" AND code != "VIP7" AND code != "VIP30" AND code != "VIP2" AND code != "VIP3" AND code != "VIP4"') do |vip_pkg|
			json.id				vip_pkg.id
			json.code 			vip_pkg.code
			json.no_day			vip_pkg.no_day
			json.price			vip_pkg.price
			json.discount		vip_pkg.discount
		end
	else
		json.details do
			json.vip						vip.vip.name
			json.image						"#{request.base_url}#{vip.vip.image.url}"
			json.weight						vip.vip.weight
			json.no_char					vip.vip.no_char
			json.screen_text_time			vip.vip.screen_text_time
			json.screen_text_effect			vip.vip.screen_text_effect
			json.kick_level					vip.vip.kick_level
			if vip.vip.clock_kick == 0
				json.clock_kick 	nil
			elsif vip.vip.clock_kick == 1
				json.clock_kick 	"Kick bởi room owner"
			else
				json.clock_kick 	"Không bị kick"
			end
			json.clock_ads					vip.vip.clock_ads
			json.exp_bonus					vip.vip.exp_bonus
		end
		json.vip_packages do
			json.id				vip.id
			json.name			vip.name
			json.code			vip.code
			json.day			vip.no_day
			json.price			vip.price
			json.discount		vip.discount
		end
	end
end