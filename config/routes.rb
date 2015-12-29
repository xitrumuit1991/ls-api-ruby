Rails.application.routes.draw do

	apipie
	devise_for :admins, controllers: { sessions: "admins/sessions" }
	root 'index#index'
	mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # ACP
  namespace :acp do
    get "/" => "index#index"

		# Broadcasters
		resources :broadcasters do
			get '/room/:id' => 'broadcasters#room'
		end

		# Room
    resources :rooms

    # Broadcaster Backgrounds
    resources :broadcaster_backgrounds

    # Schedules
    resources :schedules

    # Room Types
    resources :room_types
  	post 	'/room_types/destroy_m' => 'room_types#destroy_m'

    # Gifts
		resources :gifts
		post 	'/gifts/destroy_m' => 'gifts#destroy_m'

	 	# Broadcaster levels
		resources :broadcaster_levels
		post 	'/broadcaster_levels/destroy_m' => 'broadcaster_levels#destroy_m'

		# User levels
		resources :user_levels
		post 	'/user_levels/destroy_m' => 'user_levels#destroy_m'

		# Room actions
		resources :room_actions
		post 	'/room_actions/destroy_m' => 'room_actions#destroy_m'

    # Featureds
		resources :featureds
		post 	'/featureds/destroy_m' => 'featureds#destroy_m'

		# Home Featureds
		resources :home_featureds
		post 	'/home_featureds/destroy_m' => 'home_featureds#destroy_m'

    # Room Featureds
		resources :room_featureds
		post 	'/room_featureds/destroy_m' => 'room_featureds#destroy_m'

		# Posters
		resources :posters
		post 	'/posters/destroy_m' => 'posters#destroy_m'

    # Room Backgrounds
    resources :room_backgrounds
		post 	'/room_backgrounds/destroy_m' => 'room_backgrounds#destroy_m'

    # Room Backgrounds
    resources :slides
		post 	'/slides/destroy_m' => 'slides#destroy_m'

  end

  # API
	namespace :api, defaults: { format: :json} do
		namespace :v1 do
			# root
			get '/' => 'index#index'

			# auth
			scope '/auth' do
				get   '/logout'          => 'auth#logout'
				get  '/:forgot_code/get-password' => 'auth#setNewPassword'
				post  '/login'           => 'auth#login'
				post  '/register'        => 'auth#register'
				post  '/fb-register'     => 'auth#fbRegister'
				post  '/gp-register'     => 'auth#gpRegister'
				post  '/forgot'          => 'auth#forgotPassword'
				post  '/verify-token'    => 'auth#verifyToken'
				post  '/change'          => 'auth#changePassword'
				post  '/forgot-code'     => 'auth#updateForgotCode'
			end

			# users
			scope '/users' do
				get  '/:id/avatar'       	=> 'user#getAvatar'
				get  '/:id/cover'       	=> 'user#getBanner'
				post '/active'           	=> 'user#active'
				post '/active-fb-gp'     	=> 'user#activeFBGP'
				get  '/room'							=> 'room#getPublicRoom'
				get  '/'                 	=> 'user#profile'
				get  '/expense-records'		=> 'user#expenseRecords'
				get  '/:id'								=> 'user#publicProfile'
				put  '/'                 	=> 'user#update'
				post '/update-profile'  	=> 'user#updateProfile'
				post '/update-password'  	=> 'user#updatePassword'
				post '/avatar'          	=> 'user#uploadAvatar'
				post '/cover'           	=> 'user#uploadCover'
				post '/cover-crop'        => 'user#coverCrop'
				post '/avatar-crop'       => 'user#avatarCrop'
			end

			# broadcasters
			scope '/broadcasters' do
				get     '/'											=> 'broadcasters#myProfile'
				get		'/followed'									=> 'broadcasters#followed'
				get     '/featured'									=> 'broadcasters#getFeatured'
				get     '/home-featured'							=> 'broadcasters#getHomeFeatured'
				get     '/room-featured'							=> 'broadcasters#getRoomFeatured'
				get     '/search'									=> 'broadcasters#search'
				get     '/revcived-items'							=> 'broadcasters#broadcasterRevcivedItems'
				get     '/default-background'						=> 'broadcasters#defaultBackground'
				get     '/broadcaster-background'					=> 'broadcasters#broadcasterBackground'
				get     '/:id'										=> 'broadcasters#profile'
				post    '/status'									=> 'broadcasters#status'
				post    '/active-fb-gp'								=> 'broadcasters#activeFBGP'
				post    '/pictures'									=> 'broadcasters#pictures'
				post    '/videos'									=> 'broadcasters#videos'
				post  	'/setdefault-background'					=> 'broadcasters#setDefaultBackgroundRoom'
				post  	'/set-room-background'						=> 'broadcasters#setBackgroundRoom'
				put     '/'											=> 'broadcasters#update'
				put     '/avatar'									=> 'broadcasters#uploadAvatar'
				put     '/cover'									=> 'broadcasters#uploadCover'
				put		'/:id/follow'								=> 'broadcasters#follow'
				delete  '/pictures'									=> 'broadcasters#deletePictures'
				delete  '/videos'									=> 'broadcasters#deleteVideos'

			end

			# ranks
			scope '/ranks' do
				get     '/user-ranking'      					=> 'ranks#userRanking'
				get     '/top-heart-broadcaster'      => 'ranks#topBroadcasterRevcivedHeart'
				get     '/top-level-grow-broadcaster'	=> 'ranks#topBroadcasterLevelGrow'
				get     '/top-level-grow-user'				=> 'ranks#topUserLevelGrow'
				get     '/top-gift-broadcaster'				=> 'ranks#topBroadcasterRevcivedGift'
				get     '/top-gift-user'							=> 'ranks#topUserSendGift'
				get     '/update-datatime-top'				=> 'ranks#updateCreatedAtBroadcaster'
				get			'/top-gift-user-in-room'			=> 'ranks#topUserSendGiftRoom'
				get			'/:id/top-fans'								=> 'ranks#topUserFollowBroadcaster'
			end

			# rooms
			scope 'rooms' do
				get   	'/on-air'           		=> 'room#onair'
				get   	'/coming-soon'      		=> 'room#comingSoon'
				get   	'/room-type'        		=> 'room#roomType'
				get   	'/slug/:slug'       		=> 'room#detailBySlug'
				get   	'/actions'          		=> 'room#getActions'
				get   	'/gifts'            		=> 'room#getGifts'
				get   	'/lounges'          		=> 'room#getLounges'
				get  	'/:id/thumb'       			=> 'room#getThumb'
				put   	'/'                 		=> 'room#updateSettings'
				put   	'/thumb'            		=> 'room#uploadThumb'
				post  	'/thumb'            		=> 'room#uploadThumb'
				post  	'/thumb-crop'            		=> 'room#thumbCrop'
				put   	'/background'       		=> 'room#changeBackground'
				put   	'/background-default'   => 'room#changeBackgroundDefault'
				post  	'/background'       		=> 'room#uploadBackground'
				post  	'/background-room'      => 'room#uploadBackgroundRoom'
				post  	'/schedule'							=> 'room#updateSchedule'
				get		'/actions'								=> 'room#getActions'
				get		'/gifts'									=> 'room#getGifts'
				get		'/lounges'								=> 'room#getLounges'
				get   	'/:id'              		=> 'room#detail'
				delete  '/background'      			=> 'room#deleteBackground'
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
