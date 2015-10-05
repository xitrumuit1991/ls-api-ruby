json.id					@user.id
json.name				@user.name
json.fullname			@broadcaster.fullname
json.username			@user.username
json.email				@user.email
json.birthday			@user.birthday
json.gender				@user.gender
json.address			@user.address
json.phone				@user.phone
json.avatar				"#{request.base_url}/api/v1/users/#{@user.id}/avatar"
json.cover				"#{request.base_url}#{@user.cover.url}"
json.facebook			@user.facebook_link
json.twitter			@user.twitter_link
json.instagram			@user.instagram_link
json.heart				@broadcaster.recived_heart
json.user_exp			@user.user_exp
json.broadcaster_exp	@broadcaster.broadcaster_exp
json.description		@broadcaster.description
if defined? @user.statuses[0].content
	json.status				@user.statuses[0].content
else
	json.status				nil	
end

json.photos @broadcaster.images do |photo|
	json.id		photo.id
	json.link	"#{request.base_url}#{photo.image}"
end

json.videos @broadcaster.videos do |video|
	json.id		video.id
	json.link	video.video
	json.thumb	video.thumb
end

json.fans @followers do |follower|
	json.id		follower.id
	json.name	follower.name
	json.vip 	nil
	json.heart	follower.no_heart
end