json.id			@user.id
json.name		@user.name
json.username	@user.username
json.email		@user.email
json.birthday	@user.birthday
json.horoscope	@user.horoscope
json.gender		@user.gender
json.address	@user.address
json.phone		@user.phone
json.is_bct		@user.is_broadcaster
json.avatar     		@user.avatar_path[:avatar]
json.avatar_w60h60      @user.avatar_path[:avatar_w60h60]
json.avatar_w100h100    @user.avatar_path[:avatar_w100h100]
json.avatar_w120h120    @user.avatar_path[:avatar_w120h120]
json.avatar_w200h200    @user.avatar_path[:avatar_w200h200]
json.avatar_w240h240    @user.avatar_path[:avatar_w240h240]
json.avatar_w300h300    @user.avatar_path[:avatar_w300h300]
json.avatar_w400h400    @user.avatar_path[:avatar_w400h400]
json.cover              @user.cover_path[:cover]
json.cover_w940h200		@user.cover_path[:cover_w940h200]
json.facebook	@user.facebook_link
json.twitter	@user.twitter_link
json.instagram	@user.instagram_link
json.heart		@user.no_heart
json.money		@user.money
json.user_exp	@user.user_exp
json.percent	@user.percent
json.user_level	@user.user_level.level
if @user.is_broadcaster
	json.description @user.broadcaster.description

	json.photos @user.broadcaster.images do |photo|
		json.id		photo.id
		json.link_square	"#{request.base_url}#{photo.image.square}"
		json.link 			photo.image_path[:image]
		json.link_w160h160 	photo.image_path[:image_w160h160]
		json.link_w320h320 	photo.image_path[:image_w320h320]
		json.link_w640h640 	photo.image_path[:image_w640h640]
  	end
	json.videos @user.broadcaster.videos do |video|
		json.id		video.id
		json.link	video.video
		json.thumb 			video.thumb_path[:thum]
		json.thum_w190h108 	video.thumb_path[:thum_w190h108]
		json.thum_w380h216 	video.thumb_path[:thum_w380h216]
		json.thum_w760h432 	video.thumb_path[:thum_w760h432]
	end
end