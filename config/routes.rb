Rails.application.routes.draw do

	devise_for :admins
	mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

	namespace :api, defaults: { format: :json} do
		namespace :v1 do
			# root
			get '/' => 'index#index'

			# auth
			scope '/auth' do
				get   '/logout'          => 'auth#logout'
				post  '/login'           => 'auth#login'
				post  '/register'        => 'auth#register'
				post  '/fb-register'     => 'auth#fbRegister'
				post  '/gp-register'     => 'auth#gpRegister'
				post  '/forgot'          => 'auth#forgotPassword'
				post  '/verify-token'    => 'auth#verifyToken'
				post  '/change'          => 'auth#changePassword'
			end

			# users
			scope '/users' do
				get   '/:id/avatar'       => 'user#getAvatar'
				post  '/active'           => 'user#active'
				post  '/active-fb-gp'     => 'user#activeFBGP'
				get   '/'                 => 'user#profile'
				put   '/'                 => 'user#update'
				put   '/avatar'           => 'user#uploadAvatar'
				put   '/cover'            => 'user#uploadCover'
			end

			# broadcasters
			scope '/broadcasters' do
				get     '/'														=> 'broadcasters#myProfile'
				get			'/followed'										=> 'broadcasters#followed'
				get     '/featured'										=> 'broadcasters#getFeatured'
				get     '/home-featured'							=> 'broadcasters#getHomeFeatured'
				get     '/room-featured'							=> 'broadcasters#getRoomFeatured'
				get     '/:id'												=> 'broadcasters#profile'
				post    '/status'											=> 'broadcasters#status'
				post    '/active-fb-gp'								=> 'broadcasters#activeFBGP'
				post    '/pictures'										=> 'broadcasters#pictures'
				post    '/videos'											=> 'broadcasters#videos'
				put     '/'														=> 'broadcasters#update'
				put     '/avatar'											=> 'broadcasters#uploadAvatar'
				put     '/cover'											=> 'broadcasters#uploadCover'
				put			'/:id/follow'									=> 'broadcasters#follow'
				delete  '/pictures'										=> 'broadcasters#deletePictures'
				delete  '/videos'											=> 'broadcasters#deleteVideos'

			end

			# ranks
			scope '/ranks' do
				get     '/top-heart-broadcaster'      => 'ranks#topBroadcasterRevcivedHeart'
				get     '/top-level-grow-broadcaster'	=> 'ranks#topBroadcasterLevelGrow'
				get     '/top-level-grow-user'				=> 'ranks#topUserLevelGrow'
				get     '/top-gift-broadcaster'				=> 'ranks#topBroadcasterRevcivedGift'
				get     '/top-gift-user'							=> 'ranks#topUserSendGift'
				get     '/update-datatime-top'							=> 'ranks#updateCreatedAtBroadcaster'
				get		'/top-gift-user-in-room'		=> 'ranks#topUserSendGiftRoom'
				get		'/:id/top-fans'		=> 'ranks#topUserFollowBroadcaster'
			end

			# rooms
			scope 'rooms' do
				get   	'/on-air'           => 'room#onair'
				get   	'/coming-soon'      => 'room#comingSoon'
				get   	'/room-type'        => 'room#roomType'
				get   	'/slug/:slug'       => 'room#detailBySlug'
				get   	'/actions'          => 'room#getActions'
				get   	'/gifts'            => 'room#getGifts'
				get   	'/lounges'          => 'room#getLounges'
				put   	'/'                 => 'room#updateSettings'
				put   	'/thumb'            => 'room#uploadThumb'
				post  	'/thumb'            => 'room#uploadThumb'
				put   	'/background'       => 'room#changeBackground'
				post  	'/background'       => 'room#uploadBackground'
				post  	'/schedule'			=> 'room#updateSchedule'
				get		'/actions'			=> 'room#getActions'
				get		'/gifts'			=> 'room#getGifts'
				get		'/lounges'			=> 'room#getLounges'
				get   	'/:id'              => 'room#detail'
			end

			# Live functions
			scope 'live' do
				get   '/userlist'           => 'live#getUserList'
				post  '/send-message'       => 'live#sendMessage'
				post  '/send-screentext'    => 'live#sendScreenText'
				post  '/send-hearts'        => 'live#sendHearts'
				post  '/vote-action'        => 'live#voteAction'
				post  '/done-action'        => 'live#doneAction'
				post  '/send-gifts'         => 'live#sendGifts'
				post  '/buy-lounge'         => 'live#buyLounge'
				post  '/start-room'         => 'live#startRoom'
				post  '/end-room'           => 'live#endRoom'
				post  '/kick-user'          => 'live#kickUser'
			end

			# Posters functions
			scope 'posters' do 
				get 	'/sliders'			=>	'posters#getSliders'
				get 	'/posters'			=>	'posters#getPosters'
			end
		end
	end
end
