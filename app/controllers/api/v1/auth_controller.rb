require 'jwt'

class Api::V1::AuthController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:login, :fbRegister, :gpRegister, :register, :forgotPassword, :verifyToken]

  resource_description do
    short 'Authorization'
    formats ['json']
  end

  api! "Get token"
  param :email, String, :required => true
  param :password, String, :required => true
  error :code => 401, :desc => "Wrong email or password"
  description "Login by email and password to get token"
  example '{token: "this-is-sample-token"}'
  def login
    @user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
    if @user.present?
      # create token
      token = createToken(@user)

      # update token
      @user.update(last_login: Time.now, token: token)

      render json: {token: token}, status: 200
    else
      return head 401
    end
  end

  api! "Logout and empty token"
  error :code => 401, :desc => "Wrong email or password"
  def logout
    @user.update(token: '')
    return head 200
  end

  api! "Register"
  param :email, String, :desc => "User email", :required => true
  param :password, String, :desc => "User password", :required => true
  error :code => 400, :desc => "Can't not save user"
  error :code => 400, :desc => "Invalid input"
  def register
    activeCode = SecureRandom.hex(3).upcase
    user = User.new
    user.name     = params[:email].split("@")[0]
    user.username = params[:email].split("@")[0]
    user.email    = params[:email]
    user.password = params[:password].to_s
    user.user_level_id       = UserLevel.first().id
    user.money               = 0
    user.user_exp            = 0
    user.actived             = 0
    user.no_heart            = 0
    user.room_background_id  = RoomBackground.first().id
    user.active_code         = activeCode
    if user.valid?
      if user.save
        SendCodeJob.perform_later(user, activeCode)
        return head 201
      else
        render plain: 'System error !', status: 400
      end
    else
      render json: user.errors.messages, status: 400
    end
  end

  api! "Login/Signup by facebook account"
  param :access_token, String, :desc => "access token get from facebook login API"
  error :code => 400, :desc => "Can't not save user to database"
  error :code => 400, :desc => "Can't not fetch user info from facebook"
  example '{token: "this-is-sample-token"}'
  def fbRegister
    begin
      graph = Koala::Facebook::API.new(params[:access_token])
      profile = graph.get_object("me?fields=id,name,email,birthday,gender")
        user = User.find_by_email(profile['email'])
        if user.present?
          if user.fb_id.blank?
            user.fb_id  = profile['id']
            if user.save
              token = createToken(user)
              user.update(last_login: Time.now, token: token)
              render json: {token: token}, status: 200
            else
              render json: user.errors.messages, status: 400
            end
          else
            token = createToken(user)
            user.update(last_login: Time.now, token: token)
            render json: {token: token}, status: 200
          end
        else
          user = User.new
          user.name                     = profile['name']
          user.username                 = profile['email'].split("@")[0]
          user.email                    = profile['email']
          user.gender                   = profile['gender']
          user.user_level_id            = UserLevel.first().id
          user.money                    = 0
          user.user_exp                 = 0
          user.actived                  = 0
          user.no_heart                 = 0
          user.avatar                   = graph.get_picture(profile['id'], type: :large)
          password                      = SecureRandom.hex(5)
          user.password                 = password
          user.fb_id                    = profile['id']
          if user.save
            user = User.find_by_email(profile['email'])
            token = createToken(user)
            user.update(last_login: Time.now, token: token)
            render json: {token: token}, status: 200
          else
            render json: user.errors.messages, status: 400
          end
        end
    rescue Koala::Facebook::APIError => exc
      render json: exc, status: 400
    end
  end

  def gpRegister
    begin
      res = RestClient::Request.execute(
         :method => :get,
         :content_type => :json,
         :accept => :json,
         :url => 'https://www.googleapis.com/oauth2/v2/userinfo',
         :headers => {'Authorization' => "Bearer #{params[:access_token]}"}
      )
      profile = JSON.parse(res)

      if profile['email'] == params[:email]
        user = User.find_by_email(params[:email])
        if user.present?
          if user.gp_id.blank?
            user.gp_id  = profile['id']
            user.save
          end
        else
          user = User.new
          user.name               = profile['family_name'] + profile['given_name']
          user.email              = profile['email']
          user.remote_avatar_url  = profile['picture']
          user.password           = SecureRandom.hex(5)
          user.gp_id              = profile['id']
          user.save
        end

        # create token
        token = createToken(user)

        # update token
        user.update(last_login: Time.now, token: token)

        render json: {token: token}, status: 200
      else
        return head 400
      end
    rescue RestClient::Exception => e
      return head 401
    end
  end

  api! "verify token"
  description "Use for socket or thirtparty verify token"
  param :email, String, :desc => "Email of token owner", :required => true
  param :token, String, :required => true
  error :code => 400, :desc => "token not exist or expired"
  def verifyToken
    user = User.find_by(email: params[:email], token: params[:token])
    if user.present?
      begin
        decoded_token = JWT.decode params[:token], Settings.hmac_secret
        return head 200
      rescue JWT::ExpiredSignature
        return head 400
      end
    else
      tmp_user = TmpUser.find_by(email: params[:email], token: params[:token])
      if tmp_user.present?
        begin
          decoded_token = JWT.decode params[:token], Settings.hmac_secret
          return head 200
        rescue Exception => e
          return head 400 
        end
      else
        return head 401
      end
    end
  end

  api! "forgot password"
  param :email, String,:required => true
  error :code => 404, :desc => "Email not found"
  error :code => 400, :desc => "Can't create new password"
  def forgotPassword
    user = User.find_by_email(params[:email])
    if user.present?
      new_password    = SecureRandom.hex(5)
      user.password   = new_password
      user.token      = ''
      if user.save
        UserMailer.reset_password(user, new_password).deliver_now
        return head 200
      else
        render json: user.errors.messages, status: 400
      end
    else
      return head 404
    end
  end

  api! "change password"
  param :password, String, :desc => "new password", :required => true
  param :old_password, String, :desc => "current password", :required => true
  error :code => 401, :desc => "Unauthorized"
  error :code => 400, :desc => "Can't chnage password"
  error :code => 400, :desc => "Input invalid"
  def changePassword
    user = User.find_by(email: @user[:email]).try(:authenticate, params[:old_password])
    if user.present?
      user.password = params[:password]
      if user.valid?
        if user.save
          # create token
          token = createToken(@user)

          # update token
          @user.update(last_login: Time.now, token: token)

          render json: {token: token}, status: 200
        else
          render plain: 'System error !', status: 400
        end
      else
        render json: user.errors.messages, status: 400
      end
    else
      return head 401
    end
  end

  private
    def createToken(user)
      payload = {id: user.id, email: user.email, name: user.name, exp: Time.now.to_i + 24 * 3600}
      token = JWT.encode payload, Settings.hmac_secret, 'HS256'
    end
end