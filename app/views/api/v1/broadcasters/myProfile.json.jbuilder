json.id					@user.id
json.name				@user.name
json.fullname			@user.broadcaster.fullname
json.username			@user.username
json.email				@user.email
json.birthday			@user.birthday
json.gender				@user.gender
json.address			@user.address
json.phone				@user.phone
json.avatar				"#{request.base_url}/api/v1/users/#{@user.id}/avatar"
json.cover				"#{request.base_url}#{@user.cover.banner}"
json.facebook			@user.facebook_link
json.twitter			@user.twitter_link
json.instagram			@user.instagram_link
json.heart				@user.broadcaster.recived_heart
json.user_exp			@user.user_exp
json.bct_exp	@user.broadcaster.broadcaster_exp
json.description		@user.broadcaster.description
if defined? @user.statuses[0].content
	json.status				@user.statuses[0].content
else
	json.status				nil	
end

json.photos @user.broadcaster.images do |photo|
	json.id				photo.id
	json.link_square	"#{request.base_url}#{photo.image.square}"
	json.link			"#{request.base_url}#{photo.image_url}"
end

json.videos @user.broadcaster.videos do |video|
	json.id		video.id
	json.link	video.video
	json.thumb	"#{request.base_url}#{video.thumb.url}"
end