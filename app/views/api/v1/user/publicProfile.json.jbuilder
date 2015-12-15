json.id			@user.id
json.name		@user.name
json.username	@user.username
json.email		@user.email
json.birthday	@user.birthday
json.gender		@user.gender
json.address	@user.address
json.phone		@user.phone
json.is_bct		@user.is_broadcaster
json.avatar		"#{request.base_url}/api/v1/users/#{@user.id}/avatar"

if @user.cover.url.nil?
  "#{request.base_url}/api/v1/users/#{@user.id}/cover"
else
  json.cover		"#{request.base_url}#{@user.cover.url}"
end
json.facebook	@user.facebook_link
json.twitter	@user.twitter_link
json.instagram	@user.instagram_link
json.heart		@user.no_heart
json.money		@user.money
json.user_exp	@user.user_exp
json.percent	@user.percent
json.user_level	@user.user_level.level
if @user.is_broadcaster
	json.photos @user.broadcaster.images do |photo|
		json.id		photo.id
		json.link	"#{request.base_url}#{photo.image_url}"
		json.link_square	"#{request.base_url}#{photo.image.square}"
  end
	json.videos @user.broadcaster.videos do |video|
		json.id		video.id
		json.link	video.video
		json.thumb	"#{request.base_url}#{video.thumb.thumb}"
	end
end