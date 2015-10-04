json.id			@user.id
json.name		@user.name
json.username	@user.username
json.email		@user.email
json.birthday	@user.birthday
json.gender		@user.gender
json.address	@user.address
json.phone		@user.phone
json.avatar		"#{request.base_url}/api/v1/users/#{@user.id}/avatar"
json.cover		"#{request.base_url}@user.cover.url"
json.facebook	@user.facebook_link
json.twitter	@user.twitter_link
json.instagram	@user.instagram_link
json.heart		@user.no_heart
json.money		@user.money
json.user_exp	@user.user_exp
json.percent	@user.percent
json.user_level	@user.user_level.level
