require 'sidekiq/web'
require 'sidetiq/web'

Rails.application.routes.draw do

	apipie
	devise_for :admins, controllers: { sessions: "admins/sessions" }
	root 'index#index'
	mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
	# Sidekiq monitor
  	mount Sidekiq::Web => '/sidekiq'
  	
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
			get '/' 	=> 'index#index'
			get '/sms'  => 'user#sms'

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
				post  '/check-forgot-code'     => 'auth#check_forgotCode'
			end

			# users
			scope '/users' do
				get  '/:id/avatar'       	=> 'user#getAvatar'
				get  '/:id/cover'       	=> 'user#getBanner'
				post '/active'           	=> 'user#active'
				post '/active-fb-gp'     	=> 'user#activeFBGP'
				get  '/room'				=> 'room#getPublicRoom'
				get  '/'                 	=> 'user#profile'
				get  '/expense-records'		=> 'user#expenseRecords'
				get '/get-providers'       	=> 'user#getProviders'
				get '/get-banks'       		=> 'user#getBanks'
				get '/get-megabanks'       	=> 'user#getMegabanks'
				get  '/:id'					=> 'user#publicProfile'
				put  '/'                 	=> 'user#update'
				post '/update-profile'  	=> 'user#updateProfile'
				post '/update-password'  	=> 'user#updatePassword'
				post '/avatar'          	=> 'user#uploadAvatar'
				post '/cover'           	=> 'user#uploadCover'
				post '/cover-crop'        	=> 'user#coverCrop'
				post '/avatar-crop'       	=> 'user#avatarCrop'
				post '/payments'       		=> 'user#payments'
				post '/internet-banking'    => 'user#internetBank'
				post '/confirm'    			=> 'user#confirmEbay'
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
				get 	'/:id/thumb_mb'				=> 'room#getThumbMb'
				put   	'/'                 		=> 'room#updateSettings'
				put   	'/thumb'            		=> 'room#uploadThumb'
				post  	'/thumb'            		=> 'room#uploadThumb'
				post  	'/thumb-crop'            		=> 'room#thumbCrop'
				put   	'/background'       		=> 'room#changeBackground'
				put   	'/background-default'   => 'room#changeBackgroundDefault'
				post  	'/background'       		=> 'room#uploadBackground' # hien tai khong thay sai
				post  	'/background-room'      => 'room#uploadBackgroundRoom'
				post  	'/schedule'							=> 'room#updateSchedule'
				get		'/actions'								=> 'room#getActions' # trung voi o tren
				get		'/gifts'									=> 'room#getGifts' # trung voi o tren
				get		'/lounges'								=> 'room#getLounges' # trung voi o tren
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
