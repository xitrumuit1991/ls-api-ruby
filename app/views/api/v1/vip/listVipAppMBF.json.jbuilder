json.array! @vip do |vip|
	if @mode == 1 && vip.vip_packages.where('code = "VIP" OR code = "VIP7" OR code = "VIP30" OR code = "VIP2" OR code = "VIP3" OR code = "VIP4"').present?
		json.details do
			json.name 				vip.name
			json.image             		vip.image_path[:image]
			json.image_w60h60         vip.image_path[:image_w60h60]
			json.image_w100h100       vip.image_path[:image_w100h100]
			json.image_w120h120       vip.image_path[:image_w120h120]
			json.image_w200h200       vip.image_path[:image_w200h200]
			json.image_w300h300       vip.image_path[:image_w300h300]
			json.image_w400h400       vip.image_path[:image_w400h400]
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
		json.vip_packages vip.vip_packages.where('code = "VIP" OR code = "VIP7" OR code = "VIP30" OR code = "VIP2" OR code = "VIP3" OR code = "VIP4"') do |vip_pkg|
			json.id				vip_pkg.id
			json.name 			vip_pkg.vip.name
			json.image             		vip.image_path[:image]
			json.image_w60h60         vip.image_path[:image_w60h60]
			json.image_w100h100       vip.image_path[:image_w100h100]
			json.image_w120h120       vip.image_path[:image_w120h120]
			json.image_w200h200       vip.image_path[:image_w200h200]
			json.image_w300h300       vip.image_path[:image_w300h300]
			json.image_w400h400       vip.image_path[:image_w400h400]
			json.code 			vip_pkg.code
			json.no_day			vip_pkg.no_day
			json.price			vip_pkg.price
			json.discount		vip_pkg.discount
		end
	elsif @mode == 0
		json.details do
			json.name 				vip.name
			json.image             		vip.image_path[:image]
			json.image_w60h60         vip.image_path[:image_w60h60]
			json.image_w100h100       vip.image_path[:image_w100h100]
			json.image_w120h120       vip.image_path[:image_w120h120]
			json.image_w200h200       vip.image_path[:image_w200h200]
			json.image_w300h300       vip.image_path[:image_w300h300]
			json.image_w400h400       vip.image_path[:image_w400h400]
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
			json.name 			vip_pkg.vip.name
			json.image             		vip.image_path[:image]
			json.image_w60h60         vip.image_path[:image_w60h60]
			json.image_w100h100       vip.image_path[:image_w100h100]
			json.image_w120h120       vip.image_path[:image_w120h120]
			json.image_w200h200       vip.image_path[:image_w200h200]
			json.image_w300h300       vip.image_path[:image_w300h300]
			json.image_w400h400       vip.image_path[:image_w400h400]
			json.code 			vip_pkg.code
			json.no_day			vip_pkg.no_day
			json.price			vip_pkg.price
			json.discount		vip_pkg.discount
		end
	end
end