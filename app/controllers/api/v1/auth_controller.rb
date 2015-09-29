require 'jwt'

class Api::V1::AuthController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:login, :fbRegister, :gpRegister, :register, :forgotPassword, :verifyToken]

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

  def logout
    @user.update(token: '')
    return head 200
  end

  def register
    user = User.new
    split_email   = params[:email].split("@")
    user.email    = params[:email]
    user.password = params[:password]
    user.username = split_email[0]
    user.name     = split_email[0]

    if user.valid?
      if user.save
        activeCode = SecureRandom.hex(3).upcase
        user.update_attributes active_code: activeCode
        SendCodeJob.perform_later(user, activeCode)
        return head 201
      else
        render plain: 'System error !', status: 400
      end
    else
      render json: user.errors.messages, status: 400
    end
  end

  def fbRegister
    begin
      graph = Koala::Facebook::API.new(params[:access_token])
      profile = graph.get_object("me")
      if profile['email'] == params[:email]
        user = User.find_by_email(params[:email])
        if user.present?
          if user.fb_id.blank?
            user.fb_id  = profile['id']
            user.save
          end
        else
          user = User.new
          user.name               = profile['name']
          user.email              = profile['email']
          user.gender             = profile['gender']
          user.remote_avatar_url  = graph.get_picture(profile['id'], type: :large)
          user.password           = SecureRandom.hex(5)
          user.fb_id              = profile['id']
          user.save
        end

        # create token
        token = createToken(@user)

        # update token
        user.update(last_login: Time.now, token: token)

        render json: {token: token}, status: 200
      else
        return head 400
      end
    rescue Koala::Facebook::APIError => exc
      return head 401
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
        token = createToken(@user)

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
      return head 400
    end
  end

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
      payload = {id: @user.id, email: @user.email, name: @user.name, exp: Time.now.to_i + 24 * 3600}
      token = JWT.encode payload, Settings.hmac_secret, 'HS256'
    end
end