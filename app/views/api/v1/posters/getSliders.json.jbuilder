json.array! @sliders do |slider|
	json.id					slider.id
	json.title				slider.title
	json.description		slider.description
	json.sub_description	slider.sub_description
	json.start_time			slider.start_time ? slider.start_time.strftime('%H:%M') : ''
	json.link				slider.link
	json.thumb				slider.banner_path[:banner_w170h120]
	json.banner				slider.banner_path[:banner_w1200h480]
end
