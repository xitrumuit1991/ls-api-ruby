require 'sidekiq/web'
require 'sidetiq/web'

Rails.application.routes.draw do

  wash_out :vas
  apipie
  devise_for :admins, controllers: { sessions: "admins/sessions" }
  root 'index#index'
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # ACP
  namespace :acp do
    authenticate do
      mount Sidekiq::Web => '/sidekiq'
    end

    get "/" => "index#index"
    get "/import" => "index#import"
    get "/script" => "index#script"

    # Admin
    resources :admins

    # Users
    resources :users
    get '/users/:id/transactions' => 'users#transactions'
    get '/users/:id/history-vips' => 'users#history_vips'
    get '/users/:id/history-buy-coins' => 'users#history_buy_coins'
    get '/users/:id/history-use-coins' => 'users#history_use_coins'
    post '/users/:id/change_password' => 'users#change_password'

    # Broadcasters
    get '/broadcasters/recycle-bin' => 'broadcasters#recycle_bin'
    post '/broadcasters/trash_m' 		=> 'broadcasters#trash_m'
    post '/broadcasters/restore_m' 	=> 'broadcasters#restore_m'
    post '/broadcasters/destroy_m' 	=> 'broadcasters#destroy_m'
    resources :broadcasters do
      get '/basic' 		=> 'broadcasters#basic'
      get '/room' 				=> 'broadcasters#room'
      get '/gifts' 				=> 'broadcasters#gifts'
      get '/images' 			=> 'broadcasters#images'
      get '/videos' 			=> 'broadcasters#videos'
      get '/transactions' => 'broadcasters#transactions'
      post '/trash' 			=> 'broadcasters#trash'
      post '/restore' 		=> 'broadcasters#restore'
      post '/ajax_change_background' => 'broadcasters#ajax_change_background'
    end

    # Rooms
    resources :rooms

    # banks
    resources :banks
    post '/banks/destroy_m' => 'banks#destroy_m'

    # megabanks
    resources :megabanks
    post '/megabanks/destroy_m' => 'megabanks#destroy_m'

    # megabank_logs
    resources :megabank_logs
    post '/megabank_logs/destroy_m' => 'megabank_logs#destroy_m'

    # Sms mobile
    resources :sms_mobiles
    post '/sms_mobiles/destroy_m' => 'sms_mobiles#destroy_m'

    # Sms mobile
    resources :sms_logs
    post '/sms_logs/destroy_m' => 'sms_logs#destroy_m'

    # Sms mobile
    resources :cart_logs
    post '/cart_logs/destroy_m' => 'cart_logs#destroy_m'

    # Card 
    resources :cards
    post '/cards/destroy_m' => 'cards#destroy_m'

    # Broadcaster Backgrounds
    resources :broadcaster_backgrounds

    # Schedules
    resources :schedules

    # Broadcaster Backgrounds
    resources :bct_images
    post '/bct_images/destroy_m' => 'bct_images#destroy_m'

    # Broadcaster Backgrounds
    resources :bct_videos
    post '/bct_videos/destroy_m' => 'bct_videos#destroy_m'

    # Room Types
    resources :room_types
    post '/room_types/destroy_m' => 'room_types#destroy_m'

    # Gifts
    resources :gifts
    post '/gifts/destroy_m' => 'gifts#destroy_m'
    post '/gifts/ajax_update_handle_checkbox/:id' => 'gifts#ajax_update_handle_checkbox'

    # Gift Logs
    resources :gift_logs
    post '/gift_logs/destroy_m' => 'gift_logs#destroy_m'

    # Broadcaster levels
    resources :broadcaster_levels
    post '/broadcaster_levels/destroy_m' => 'broadcaster_levels#destroy_m'

    # User levels
    resources :user_levels
    post '/user_levels/destroy_m' => 'user_levels#destroy_m'

    # Room actions
    resources :room_actions
    post '/room_actions/destroy_m' => 'room_actions#destroy_m'
    post '/room_actions/ajax_update_handle_checkbox/:id' => 'room_actions#ajax_update_handle_checkbox'

    # Featureds
    resources :featureds
    post '/featureds/destroy_m' => 'featureds#destroy_m'

    # Home Featureds
    resources :home_featureds
    post '/home_featureds/destroy_m' => 'home_featureds#destroy_m'

    # Room Featureds
    resources :room_featureds
    post '/room_featureds/destroy_m' => 'room_featureds#destroy_m'

    # Posters
    resources :posters
    post '/posters/destroy_m' => 'posters#destroy_m'

    # Room Backgrounds
    resources :room_backgrounds
    post '/room_backgrounds/destroy_m' => 'room_backgrounds#destroy_m'

    # Room Backgrounds
    resources :slides
    post '/slides/destroy_m' => 'slides#destroy_m'

    # Vips
    resources :vips
    post '/vips/destroy_m' => 'vips#destroy_m'

    # Vip Packages
    resources :vip_packages
    post '/vip_packages/destroy_m' => 'vip_packages#destroy_m'

    # Trade Logs
    resources :trade_logs
    post '/trade_logs/destroy_m' => 'trade_logs#destroy_m'

    # Roles
    get '/roles/test' => 'roles#test'
    resources :roles

    # Resources
    get '/resources/sync' => 'resources#sync'
    resources :resources

    # Reports
    get '/reports/users' => 'reports#users'
    get '/reports/user-online' => 'reports#user_online'
    get '/reports/user-send-gifts' => 'reports#user_send_gifts'
    get '/reports/user-send-hearts' => 'reports#user_send_hearts'
    get '/reports/idols' => 'reports#idols'
    get '/reports/idol-receive-coins' => 'reports#idol_receive_coins'
    get '/reports/idol-receive-hearts' => 'reports#idol_receive_hearts'
    get '/reports/sms' => 'reports#sms'
    get '/reports/card' => 'reports#card'
    get '/reports/bank' => 'reports#bank'
    resources :reports

    # Caches
    get '/caches/index' => 'caches#index'
    post '/caches/clear-cache-clider' => 'caches#clearCacheClider'
    post '/caches/clear-cache-poster' => 'caches#clearCachePoster'
    resources :caches

  end

  # API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # root
      get '/' => 'index#index'
      get '/msisdn' => 'index#msisdn'

      # auth
      scope '/auth' do
        get '/logout' => 'auth#logout'
        post '/login' => 'auth#login'
        post '/register' => 'auth#register'
        post '/fb-register' => 'auth#fbRegister'
        post '/gp-register' => 'auth#gpRegister'
        post '/verify-token' => 'auth#verifyToken'
        post '/change' => 'auth#changePassword'
        post '/update-forgot-code' => 'auth#updateForgotCode'
        post '/reset-password' => 'auth#setNewPassword'
        post '/check-user-mbf' => 'auth#check_user_mbf'
        # For mobifone only
        get   '/mobifone' 			=> 'auth#mbf_detection'
        post  '/mobifone/login' => 'auth#mbf_login'
        post  '/mobifone' 			=> 'auth#mbf_register'
        put   '/mobifone' 			=> 'auth#mbf_sync'
        patch '/mobifone' 			=> 'auth#mbf_verify'
        # Wap
        get   'wap-mbf-register' => 'auth#wap_mbf_register_request'
        post 	'wap-mbf-register' => 'auth#wap_mbf_register_response'
      end

      # users
      scope '/users' do
        get '/:id/avatar' => 'user#getAvatar'
        get '/:id/real-avatar' => 'user#real_avatar'
        get '/:id/cover' => 'user#getBanner'
        get '/trades' => 'user#getTradeHistory' #
        post '/active' => 'user#active' #
        post '/active-fb-gp' => 'user#activeFBGP'
        get '/sms' => 'user#sms'
        get '/room' => 'room#getPublicRoom'
        get '/' => 'user#profile' #
        get '/expense-records' => 'user#expenseRecords' #
        get '/get-providers' => 'user#getProviders'
        get '/get-sms' => 'user#getSms' # de sau, chua doi
        get '/get-banks' => 'user#getBanks'
        get '/get-megabanks' => 'user#getMegabanks'
        get '/:username' => 'user#publicProfile' #
        put '/' => 'user#update' #
        post '/share-fb-received-coin' => 'user#shareFBReceivedCoin' #
        post '/update-password' => 'user#updatePassword'
        post '/avatar' => 'user#uploadAvatar' #
        post '/cover' => 'user#uploadCover' #
        post '/cover-crop' => 'user#coverCrop'
        post '/avatar-crop' => 'user#avatarCrop'
        post '/payments' => 'user#payments' # Để sau, chưa đổi
        post '/internet-banking' => 'user#internetBank' # Để sau, chưa đổi
        post '/confirm' => 'user#confirmEbay' # Để sau, chưa đổi
      end

      # broadcasters
      scope '/broadcasters' do
        get '/' => 'broadcasters#myProfile' #
        get '/followed' => 'broadcasters#followed' #
        get '/featured' => 'broadcasters#getFeatured' #
        get '/home-featured' => 'broadcasters#getHomeFeatured' #
        get '/room-featured' => 'broadcasters#getRoomFeatured' #
        get '/search' => 'broadcasters#search' #
        get '/revcived-items' => 'broadcasters#broadcasterRevcivedItems' #
        get '/default-background' => 'broadcasters#defaultBackground' # api is not using
        get '/broadcaster-background' => 'broadcasters#broadcasterBackground' # api is not using
        get '/top-hearter' => 'broadcasters#reportTopHearter' #
        get '/top-spender' => 'broadcasters#reportTopSpender' #
        get '/:id' => 'broadcasters#profile' #
        post '/status' => 'broadcasters#status' # #Liem - Không thấy dùng bên web
        post '/pictures' => 'broadcasters#pictures' #
        post '/videos' => 'broadcasters#videos' #
        post '/select-gift' => 'broadcasters#selectGift' #
        post '/select-action' => 'broadcasters#selectAction' #
        post '/select-all-gift' => 'broadcasters#selectAllGift' #
        post '/select-all-action' => 'broadcasters#selectAllAction' #
        put '/' => 'broadcasters#update' # Liem khong thay function nay trong broadcasters_controller
        put '/avatar' => 'broadcasters#uploadAvatar' # api is not using
        put '/cover' => 'broadcasters#uploadCover' # api is not using
        put '/:id/follow' => 'broadcasters#follow' #
        delete '/pictures' => 'broadcasters#deletePictures' #
        delete '/videos' => 'broadcasters#deleteVideos' #

      end

      # ranks
      scope '/ranks' do
        get '/user-ranking' => 'ranks#userRanking'
        get '/top-heart-broadcaster' => 'ranks#topBroadcasterRevcivedHeart'
        get '/top-level-grow-broadcaster' => 'ranks#topBroadcasterLevelGrow'
        get '/top-level-grow-user' => 'ranks#topUserLevelGrow'
        get '/top-gift-broadcaster' => 'ranks#topBroadcasterRevcivedGift'
        get '/top-gift-user' => 'ranks#topUserSendGift'
        get '/update-datatime-top' => 'ranks#updateCreatedAtBroadcaster'
        get '/:room_id/top-user-use-in-room' => 'ranks#topUserUseMoneyRoom'
        get '/:room_id/top-user-use-money' => 'ranks#topUserUseMoneyCurrent'
        get '/:id/top-fans' => 'ranks#topUserFollowBroadcaster'
        get '/topWeek' => 'ranks#topWeek'
        get '/topMonth' => 'ranks#topMonth'
        get '/topYear' => 'ranks#topYear'
        get '/optimize-users' => 'ranks#optimizeImageUsers'
        get '/optimize-rooms' => 'ranks#optimizeImagerooms'
        get '/optimize-bct-image' => 'ranks#optimizeImageBctImage'
        get '/optimize-bct-video' => 'ranks#optimizeImageBctVideo'
        get '/optimize-bct-background' => 'ranks#optimizeImageBctBackground'
        get '/optimize-gift' => 'ranks#optimizeGift'
        get '/optimize-poster' => 'ranks#optimizePoster'
        get '/optimize-room-action' => 'ranks#optimizeImageRoomAction'
        get '/optimize-room-background' => 'ranks#optimizeRoomBackground'
        get '/optimize-slide' => 'ranks#optimizeImageSlide'
        get '/optimize-vip' => 'ranks#optimizeImageVip'
        get '/update-name-email-u' => 'ranks#updateNameEmailUserMBF'
      end

      # rooms
      scope 'rooms' do
        get '/on-air' => 'room#onair' #
        get '/my-idol' => 'room#myIdol' #
        get '/coming-soon' => 'room#comingSoon' #
        get '/room-type' => 'room#roomType'
        get '/slug/:slug' => 'room#detailBySlug'
        get '/actions' => 'room#getActions' #
        get '/gifts' => 'room#getGifts' #
        get '/lounges' => 'room#getLounges' #
        get '/:id/thumb' => 'room#getThumb'
        get '/:id/thumb_mb' => 'room#getThumbMb'
        get '/:id' => 'room#detail' #
        post '/thumb' => 'room#uploadThumb' #
        post '/thumb-crop' => 'room#thumbCrop'
        post '/background' => 'room#uploadBackground' #
        post  '/schedule'	=> 'room#updateSchedule'
        put '/background' => 'room#changeBackground'
        put '/background-default' => 'room#changeBackgroundDefault'
        put '/' => 'room#updateSettings' #
        put '/thumb' => 'room#uploadThumb' #
        delete '/background' => 'room#deleteBackground'
        delete '/schedule' => 'room#deleteSchedule'
      end

      # Live functions
      scope 'live' do
        get '/userlist' => 'live#getUserList'
        post '/add-heart' => 'live#addHeartInRoom'
        post '/send-message' => 'live#sendMessage'
        post '/send-screentext' => 'live#sendScreenText'
        post '/send-hearts' => 'live#sendHearts'
        post '/vote-action' => 'live#voteAction'
        post '/done-action' => 'live#doneAction'
        post '/send-gifts' => 'live#sendGifts'
        post '/buy-lounge' => 'live#buyLounge'
        post '/start-room' => 'live#startRoom'
        post '/end-room' => 'live#endRoom'
        post '/kick-user' => 'live#kickUser'
      end
      # Vip
      scope 'vips' do
        get   '/:day/list-vip'         => 'vip#listVip'
        get   '/list-vip-web-mbf'      => 'vip#listVipWebMBF'
        get     '/confirm-vip'         => 'vip#confirmVip'
        post    '/buy-vip'             => 'vip#buyVip'
        # For Mobifone
        get   '/list-vip-app-mbf'       => 'vip#listVipAppMBF'
        get 	'/mobifone' => 'vip#mbf_get_vip_packages'
        post 	'/mobifone' => 'vip#mbf_subscribe_vip_package'
      end

      # IAP
      scope 'iap' do
        get 	'/coins' 		=> 'iap#get_coins'
        post 	'/android' 	=> 'iap#android'
        post 	'/ios' 			=> 'iap#ios'
      end

      # Posters functions
      scope 'posters' do
        get '/sliders' => 'posters#getSliders'
        get '/posters' => 'posters#getPosters'
      end
    end
  end
end
