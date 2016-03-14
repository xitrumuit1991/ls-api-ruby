  json.totalPage @max_page
json.broadcasters @bcts do |bct|
	json.id			bct.id
	json.name		bct.user.name
	json.username	bct.user.username
	json.avatar		bct.user.avatar_path
	json.heart		bct.user.no_heart
	json.user_exp	bct.user.user_exp
	if !bct.user.user_level.nil?
		json.level		bct.user.user_level.level
  end
  if @user != nil
    json.isFollow		!@user.broadcasters.where(id: bct.id).empty?
  else
    json.isFollow		false
  end
	if !bct.user.public_room.nil?
		json.room do
			json.id			bct.user.public_room.id
			json.title		bct.user.public_room.title
			json.slug		bct.user.public_room.slug
			json.on_air		bct.user.public_room.on_air
      json.thumb		"#{request.base_url}/api/v1/rooms/#{bct.user.public_room.id}/thumb"
      json.thumb_mb		"#{request.base_url}/api/v1/rooms/#{bct.user.public_room.id}/thumb_mb"
		end
		if !bct.user.public_room.on_air and bct.user.public_room.schedules.length > 0
			json.schedule bct.rooms.find_by_is_privated(false).schedules do |schedule|
				json.date	schedule.start.strftime('%d/%m')
				json.start	schedule.start.strftime('%H:%M')
			end
		else
			json.schedule nil
		end
	else
		json.room nil
		json.schedule nil
	end
end