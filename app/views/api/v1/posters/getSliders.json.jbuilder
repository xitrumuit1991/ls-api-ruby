json.array! @sliders do |slider|
	json.id					slider.id
	json.title				slider.title
	json.description		slider.description
	json.sub_description	slider.sub_description
	json.start_time			slider.start_time ? slider.start_time.strftime('%H:%M') : ''
	json.link				slider.link
	json.banner				"#{request.base_url}#{slider.banner.banner}"
	json.thumb				"#{request.base_url}#{slider.banner.thumb}"
end	