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
				get     '/'                 => 'broadcasters#myProfile'
				post    '/status'           => 'broadcasters#status'
				post    '/active-fb-gp'     => 'broadcasters#activeFBGP'
				put     '/'                 => 'broadcasters#update'
				put     '/avatar'           => 'broadcasters#uploadAvatar'
				put     '/cover'            => 'broadcasters#uploadCover'
				post    '/pictures'         => 'broadcasters#pictures'
				delete  '/pictures'         => 'broadcasters#deletePictures'
				post    '/videos'						=> 'broadcasters#videos'
				delete  '/videos'						=> 'broadcasters#deleteVideos'
				get			'/followed'					=> 'broadcasters#followed'
				get     '/:id'              => 'broadcasters#profile'
				put			'/:id/follow'       => 'broadcasters#follow'
			end

			# rooms
			scope 'rooms' do
				get   '/on-air'           => 'room#onair'
				get   '/coming-soon'      => 'room#comingSoon'
				get   '/slug/:slug'       => 'room#detailBySlug'
				put   '/'                 => 'room#updateSettings'
				post  '/thumb'            => 'room#uploadThumb'
				put   '/thumb'            => 'room#uploadThumb'
				post  '/background'       => 'room#uploadBackground'
				put   '/background'       => 'room#changeBackground'
				post  '/schedule'					=> 'room#updateSchedule'
				get		'/actions'					=> 'room#getActions'
				get		'/gifts'					=> 'room#getGifts'
				get		'/lounges'					=> 'room#getLounges'
				get   '/:id'              => 'room#detail'
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
		end
	end
end
