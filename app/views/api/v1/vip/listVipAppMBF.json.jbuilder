json.name 				@vip.id
json.image				"#{request.base_url}#{@vip.image}"
json.no_char			@vip.no_char
json.screen_text_time	@vip.screen_text_time
json.screen_text_effect	@vip.screen_text_effect
json.kick_level			@vip.kick_level = 0 ? 'Kick User phổ thông' : 'Kich Vip'+@vip.kick_level+' trở Xuống'
if @vip.clock_kick == 0
	json.clock_kick 	0
elsif @vip.clock_kick == 1
	json.clock_kick 	"Kick bởi room owner"
else
	json.clock_kick 	"Không bị kick"
end
json.exp_bonus				@vip.exp_bonus
json.vip_packages @vip.vip_packages.where('name IS NOT NULL') do |vip_pkg|
	json.id				vip_pkg.id
	json.no_day			vip_pkg.no_day
	json.price			vip_pkg.price
	json.discount		vip_pkg.discount
end