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
json.avatar			@user.avatar_path
json.cover			@user.cover_path
json.facebook		@user.facebook_link
json.twitter		@user.twitter_link
json.instagram		@user.instagram_link
json.heart			@user.no_heart
json.money			@user.money
json.user_exp		@user.user_exp
json.percent		@user.percent
json.user_level		@user.user_level.level
json.active_code	@user.active_code
json.limitChar   @limitChar
json.screenTime   @screenTextTime
if @user.is_broadcaster
	json.room do
		json.slug 	@user.broadcaster.rooms.order("is_privated DESC").first.slug
	end
end
