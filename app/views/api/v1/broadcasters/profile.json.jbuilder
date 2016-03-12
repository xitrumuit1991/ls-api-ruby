json.id					@user.id
json.name				@user.name
json.fullname			@broadcaster.fullname
json.username			@user.username
json.email				@user.email
json.birthday			@user.birthday
json.horoscope			"Updating"
json.gender				@user.gender
json.address			@user.address
json.phone				@user.phone
json.avatar				@user.avatar_path
json.cover				"#{request.base_url}/api/v1/users/#{@user.id}/cover?timestamp=#{@user.updated_at.to_i}"
json.facebook			@user.facebook_link
json.twitter			@user.twitter_link
json.instagram			@user.instagram_link
json.heart				@broadcaster.recived_heart
json.user_level			@user.user_level.level
json.broadcaster_level	@broadcaster.broadcaster_level.level
json.percent			@broadcaster.percent
json.user_exp			@user.user_exp
json.bct_exp			@broadcaster.broadcaster_exp
json.description		@broadcaster.description
if defined? @user.statuses[0].content
	json.status			@user.statuses[0].content
else
	json.status			0
end
json.photos @broadcaster.images do |photo|
	json.id				photo.id
	json.link_square	"#{request.base_url}#{photo.image.square}"
	json.link			"#{request.base_url}#{photo.image_url}"
end
json.videos @broadcaster.videos do |video|
	json.id		video.id
	json.link	video.video

	if video.thumb.url.nil?
	    video_id = youtubeID(video.video)
	    json.thumb "http://img.youtube.com/vi/#{video_id}/hqdefault.jpg"
	else
	    json.thumb	"#{request.base_url}#{video.thumb.url}"
	end
end
json.fan @fan do |item|
	json.id				item.user.id
	json.name			item.user.name
	json.vip 			1
	json.username	item.user.username
  json.heart		item.total
end