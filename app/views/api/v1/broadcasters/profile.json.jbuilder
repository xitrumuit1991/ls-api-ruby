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
json.avatar				"#{request.base_url}/api/v1/users/#{@user.id}/avatar"
if @user.cover.url.nil?
  json.cover			"#{request.base_url}/api/v1/users/#{@user.id}/cover"
else
  json.cover			"#{request.base_url}#{@user.cover.url}"
end
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
	json.status			nil	
end
json.photos @broadcaster.images do |photo|
	json.id		photo.id
	json.link	"#{request.base_url}#{photo.image_url}"
end
json.videos @broadcaster.videos do |video|
	json.id		video.id
	json.link	video.video
	json.thumb	"#{request.base_url}#{video.thumb.url}"
end
json.fans @followers do |follower|
	json.id			follower.user_id
	json.name		follower.name
	json.vip 		nil
	json.username	follower.username
	json.avatar		"#{request.base_url}/api/v1/users/#{follower.user_id}/avatar"
	json.heart		follower.no_heart
	json.money		follower.total_money
	json.user_exp	follower.user_exp
	json.level		UserLevel.find(follower.user_level_id).level
end