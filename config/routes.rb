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
          post '/forgot'          => 'auth#resetPassword'
          post '/verify-token'    => 'auth#verifyToken'
          post '/change'          => 'auth#changePassword'
        end

	    end
  	end
end
