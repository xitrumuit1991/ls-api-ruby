Rails.application.routes.draw do

  devise_for :admins
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

    namespace :api, defaults: { format: :json} do
	    namespace :v1 do
      	# root
      	get '/' => 'index#index'

        # auth
        scope '/auth' do
          get '/logout'           => 'auth#logout'
          post '/login'           => 'auth#login'
          post '/register'        => 'auth#register'
          post '/fb-register'     => 'auth#fbRegister'
          post '/gp-register'     => 'auth#gbRegister'
          post '/forgot'          => 'auth#resetPassword'
          post '/verify-token'    => 'auth#verifyToken'
          post '/change'          => 'auth#changePassword'
        end

        # users
        scope '/users' do
          post '/active'          => 'user#active'
          post '/active-fb-gp'    => 'user#activeByID'
          get '/'                 => 'user#getProfile'
          put '/'                 => 'user#update'
          put '/avatar'           => 'user#uploadAvatar'
        end

        # rooms
        scope 'rooms' do
          get '/'                 => 'room#roomDetails'
        end
	    end
  	end
end
