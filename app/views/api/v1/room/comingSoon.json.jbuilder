json.totalPage @totalPage
json.rooms @schedules do |schedule|
	json.id			schedule.room.id
	json.title		schedule.room.title
	json.slug		schedule.room.slug
	json.thumb		schedule.room.thumb_path
	json.thumb_mb	schedule.room.thumb_path(true)
	json.date		schedule.start.strftime('%d/%m')
	json.start		schedule.start.strftime('%H:%M')
	json.broadcaster do
		json.id		schedule.room.broadcaster.user.id
		json.bct_id		schedule.room.broadcaster.id
		json.name	schedule.room.broadcaster.user.name
		json.avatar	schedule.room.broadcaster.user.avatar_path
		json.heart	schedule.room.broadcaster.recived_heart
		json.exp	schedule.room.broadcaster.broadcaster_exp
		json.level	schedule.room.broadcaster.broadcaster_level.level
    if @user != nil
      json.isFollow		!@user.broadcasters.where(id: schedule.room.broadcaster.id).empty?
    else
      json.isFollow		false
    end
	end
end
