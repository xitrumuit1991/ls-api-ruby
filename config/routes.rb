require 'sidekiq/web'
require 'sidetiq/web'

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
			get 		'/basic/:id' => 'broadcasters#basic'
			get 		'/room' => 'broadcasters#room'
			get 		'/gifts' => 'broadcasters#gifts'
			get 		'/images' => 'broadcasters#images'
			get 		'/videos' => 'broadcasters#videos'
			get 		'/transactions' => 'broadcasters#transactions'
			post 		'/ajax_change_background' => 'broadcasters#ajax_change_background'
		end

		authenticate do
			mount Sidekiq::Web => '/sidekiq'
		end

		# Users
    resources :users
  	get 	'/users/:id/transactions' => 'users#transactions'
  	post 	'/users/:id/change_password' => 'users#change_password'

		# Rooms
    resources :rooms

    # banks
    resources :banks
    	post 	'/banks/destroy_m' => 'banks#destroy_m'

    # megabanks
    resources :megabanks
    	post 	'/megabanks/destroy_m' => 'megabanks#destroy_m'

    # megabank_logs
    resources :megabank_logs
    	post 	'/megabank_logs/destroy_m' => 'megabank_logs#destroy_m'

    # Sms mobile
    resources :sms_mobiles
    	post 	'/sms_mobiles/destroy_m' => 'sms_mobiles#destroy_m'

    # Sms mobile
    resources :sms_logs
    	post 	'/sms_logs/destroy_m' => 'sms_logs#destroy_m'

    # Sms mobile
    resources :cart_logs
    	post 	'/cart_logs/destroy_m' => 'cart_logs#destroy_m'

    # Card 
    resources :cards
    	post 	'/cards/destroy_m' => 'cards#destroy_m'

    # Broadcaster Backgrounds
    resources :broadcaster_backgrounds

    # Schedules
    resources :schedules

    # Broadcaster Backgrounds
    resources :bct_images
		post 	'/bct_images/destroy_m' => 'bct_images#destroy_m'

    # Broadcaster Backgrounds
    resources :bct_videos
		post 	'/bct_videos/destroy_m' => 'bct_videos#destroy_m'

    # Room Types
    resources :room_types
  	post 	'/room_types/destroy_m' => 'room_types#destroy_m'

    # Gifts
		resources :gifts
		post 	'/gifts/destroy_m' => 'gifts#destroy_m'
		post 	'/gifts/ajax_update_handle_checkbox/:id' => 'gifts#ajax_update_handle_checkbox'

		# Gift Logs
		resources :gift_logs
		post 	'/gift_logs/destroy_m' => 'gift_logs#destroy_m'

	 	# Broadcaster levels
		resources :broadcaster_levels
		post 	'/broadcaster_levels/destroy_m' => 'broadcaster_levels#destroy_m'

		# User levels
		resources :user_levels
		post 	'/user_levels/destroy_m' => 'user_levels#destroy_m'

		# Room actions
		resources :room_actions
		post 	'/room_actions/destroy_m' => 'room_actions#destroy_m'
		post 	'/room_actions/ajax_update_handle_checkbox/:id' => 'room_actions#ajax_update_handle_checkbox'

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

		# Vips
		resources :vips
		post 	'/vips/destroy_m' => 'vips#destroy_m'

		# Vip Packages
		resources :vip_packages
		post 	'/vip_packages/destroy_m' => 'vip_packages#destroy_m'

		# Trade Logs
		resources :trade_logs
		post 	'/trade_logs/destroy_m' => 'trade_logs#destroy_m'

  end

  # API
	namespace :api, defaults: { format: :json} do
		namespace :v1 do
			# root
			get '/' 				=> 'index#index'
			get '/msisdn' 	=> 'index#msisdn'

			# auth
			scope '/auth' do
				get   '/logout'          						=> 'auth#logout'
				get  '/:forgot_code/get-password' 	=> 'auth#setNewPassword'
				post  '/login'           						=> 'auth#login'
				post  '/register'        						=> 'auth#register'
				post  '/fb-register'     						=> 'auth#fbRegister'
				post  '/gp-register'     						=> 'auth#gpRegister'
				post  '/verify-token'    						=> 'auth#verifyToken'
				post  '/change'          						=> 'auth#changePassword'
				post  '/update-forgot-code' 				=> 'auth#updateForgotCode'
				post  '/reset-password'     				=> 'auth#setNewPassword'
			end

			# users
			scope '/users' do
				get  '/:id/avatar'       	=> 'user#getAvatar'
				get  '/:id/cover'       	=> 'user#getBanner'
				get '/trades'							=> 'user#getTradeHistory' #
				post '/active'           	=> 'user#active' #
				post '/active-fb-gp'     	=> 'user#activeFBGP'
				get '/sms'  							=> 'user#sms'
				get  '/room'							=> 'room#getPublicRoom'
				get  '/'                 	=> 'user#profile' #
				get  '/expense-records'		=> 'user#expenseRecords' #
				get '/get-providers'      => 'user#getProviders'
				get '/get-banks'       		=> 'user#getBanks'
				get '/get-megabanks'      => 'user#getMegabanks'
				get  '/check-captcha'			=> 'user#checkRecaptcha' #
				get  '/:username'					=> 'user#publicProfile' #
				put  '/'                 	=> 'user#update' #
				post '/update-profile'  	=> 'user#updateProfile'
				post '/update-password'  	=> 'user#updatePassword'
				post '/avatar'          	=> 'user#uploadAvatar' #
				post '/cover'           	=> 'user#uploadCover' #
				post '/cover-crop'        => 'user#coverCrop'
				post '/avatar-crop'       => 'user#avatarCrop'
				post '/payments'       		=> 'user#payments'
				post '/internet-banking'  => 'user#internetBank'
				post '/confirm'    				=> 'user#confirmEbay'
			end

			# broadcasters
			scope '/broadcasters' do
				get     '/'												=> 'broadcasters#myProfile' #
				get			'/followed'								=> 'broadcasters#followed' #
				get     '/featured'								=> 'broadcasters#getFeatured' #
				get     '/home-featured'					=> 'broadcasters#getHomeFeatured' #
				get     '/room-featured'					=> 'broadcasters#getRoomFeatured' #
				get     '/search'									=> 'broadcasters#search' #
				get     '/revcived-items'					=> 'broadcasters#broadcasterRevcivedItems' #
				get     '/default-background'			=> 'broadcasters#defaultBackground' # api is not using
				get     '/broadcaster-background'	=> 'broadcasters#broadcasterBackground' # api is not using
				get     '/:id'										=> 'broadcasters#profile' #
				post    '/status'									=> 'broadcasters#status' #
				post    '/pictures'								=> 'broadcasters#pictures' #
				post    '/videos'									=> 'broadcasters#videos' #
				post  	'/setdefault-background'	=> 'broadcasters#setDefaultBackgroundRoom' # api is not using
				post  	'/set-room-background'		=> 'broadcasters#setBackgroundRoom' # api is not using
				put     '/'												=> 'broadcasters#update'
				put     '/avatar'									=> 'broadcasters#uploadAvatar' # api is not using
				put     '/cover'									=> 'broadcasters#uploadCover' # api is not using
				put			'/:id/follow'							=> 'broadcasters#follow' #
				delete  '/pictures'								=> 'broadcasters#deletePictures' #
				delete  '/videos'									=> 'broadcasters#deleteVideos' #

			end

			# ranks
			scope '/ranks' do
				get   '/user-ranking'      							=> 'ranks#userRanking'
				get   '/top-heart-broadcaster'      		=> 'ranks#topBroadcasterRevcivedHeart'
				get   '/top-level-grow-broadcaster'			=> 'ranks#topBroadcasterLevelGrow'
				get   '/top-level-grow-user'						=> 'ranks#topUserLevelGrow'
				get   '/top-gift-broadcaster'						=> 'ranks#topBroadcasterRevcivedGift'
				get   '/top-gift-user'									=> 'ranks#topUserSendGift'
				get 	'/update-datatime-top'						=> 'ranks#updateCreatedAtBroadcaster'
				get		'/:room_id/top-user-use-in-room'	=> 'ranks#topUserUseMoneyRoom'
				get		'/:room_id/top-user-use-money'		=> 'ranks#topUserUseMoneyCurrent'
				get		'/:id/top-fans'										=> 'ranks#topUserFollowBroadcaster'
				get		'/topWeek'												=> 'ranks#topWeek'
				get		'/topMonth'												=> 'ranks#topMonth'
				get		'/topYear'												=> 'ranks#topYear'
			end

			# rooms
			scope 'rooms' do
				get   	'/on-air'          		=> 'room#onair' #
				get   	'/coming-soon'     		=> 'room#comingSoon' #
				get   	'/room-type'       		=> 'room#roomType'
				get   	'/slug/:slug'      		=> 'room#detailBySlug'
				get   	'/actions'         		=> 'room#getActions' #
				get   	'/gifts'            	=> 'room#getGifts' #
				get   	'/lounges'          	=> 'room#getLounges' #
				get  		'/:id/thumb'       		=> 'room#getThumb'
				get 		'/:id/thumb_mb'				=> 'room#getThumbMb'
				put   	'/'                 	=> 'room#updateSettings' #
				put   	'/thumb'            	=> 'room#uploadThumb' #
				post  	'/thumb'            	=> 'room#uploadThumb' #
				post  	'/thumb-crop'         => 'room#thumbCrop'
				put   	'/background'       	=> 'room#changeBackground'
				put   	'/background-default'	=> 'room#changeBackgroundDefault'
				post  	'/background'       	=> 'room#uploadBackground' #
				post  	'/schedule'						=> 'room#updateSchedule' #
				get   	'/:id'              	=> 'room#detail' #
				delete  '/background'      		=> 'room#deleteBackground'
			end

			# Live functions
			scope 'live' do
				get   '/userlist'           => 'live#getUserList'
				post 	'/add-heart' 					=> 'live#addHeartInRoom'
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

			# Live functions
			scope 'vip' do
				get  '/:day/list-vip'       => 'vip#listVip'
				post  '/buy-vip'       => 'vip#buyVip'
			end

			# Posters functions
			scope 'posters' do 
				get 	'/sliders'			=>	'posters#getSliders'
				get 	'/posters'			=>	'posters#getPosters'
			end
		end
	end
end
