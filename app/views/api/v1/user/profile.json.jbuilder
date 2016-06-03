json.id			@user.id
json.name		@user.name
json.username	@user.username
json.email		@user.email
if @user.birthday
  json.birthday	@user.birthday.strftime('%d-%m-%Y')
else
  json.birthday	''
end
json.gender			@user.gender
json.address		@user.address
json.phone			@user.phone
json.is_bct			@user.is_broadcaster
json.avatar     @user.avatar_path[:avatar]
json.avatar_w60h60      @user.avatar_path[:avatar_w60h60]
json.avatar_w100h100    @user.avatar_path[:avatar_w100h100]
json.avatar_w120h120    @user.avatar_path[:avatar_w120h120]
json.avatar_w200h200    @user.avatar_path[:avatar_w200h200]
json.avatar_w240h240    @user.avatar_path[:avatar_w240h240]
json.avatar_w300h300    @user.avatar_path[:avatar_w300h300]
json.avatar_w400h400    @user.avatar_path[:avatar_w400h400]
json.cover              @user.cover_path[:cover]
json.cover_w940h200			@user.cover_path[:cover_w940h200]
json.facebook		@user.facebook_link
json.twitter		@user.twitter_link
json.instagram		@user.instagram_link
json.heart			@user.no_heart
json.money			@user.money
json.user_exp		@user.user_exp
json.percent		@user.percent
json.user_level		@user.user_level.level
json.max_heart		@user.user_level.heart_per_day
json.active_code	@user.active_code
json.is_mbf       @user.mobifone_user.present?
if !@vipInfo.nil?
  json.vip do
    json.vip 			@vipInfo.weight
    json.no_char 	    @vipInfo.no_char
    json.screen_time 	@vipInfo.screen_text_time
  end
end
if @user.is_broadcaster
	json.room do
		json.slug 	@user.broadcaster.rooms.order("is_privated DESC").first.slug
	end
end
