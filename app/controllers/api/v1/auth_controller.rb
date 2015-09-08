require 'jwt'

class Api::V1::AuthController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:login, :loginFB, :register, :resetPassword, :verifyToken]

  def show
  end

  def login
    data = Hash.new
    @user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
    if @user.present?
      # create token
      payload = {id: @user.id, email: @user.email, exp: Time.now.to_i + 24 * 3600 * 30}
      token = JWT.encode payload, Settings.hmac_secret, 'HS256'
      data[:token] = token
      # update token
      @user.update(last_login: Time.now, token: token)

      render json: data, status: 200
    else
      return head 401
    end
  end

  def loginFB
    data = Hash.new
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
          password = SecureRandom.hex(5)
          user.name                   = profile['name']
          user.email                  = profile['email']
          user.password               = password
          user.gender                 = profile['gender']
          user.remote_avatar_url      = graph.get_picture(profile['id'], type: :large)
          user.fb_id                  = profile['id']
          user.timezone               = profile['timezone'].to_s
          user.dob                    = params['dob']
          user.tob                    = params['tob']

          user.save
        end

        # create token
        payload = {id: user.id, email: user.email, exp: Time.now.to_i + 24 * 3600}
        token = JWT.encode payload, Settings.hmac_secret, 'HS256'

        # update token
        user.update(last_login: Time.now, token: token)

        data[:token] = token
        render json: data, status: 200
      else
        return head 400
      end

    rescue Koala::Facebook::APIError => exc
      return head 401
    end
  end

  def logout
    @user.update(token: '')
    return head 200
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

  def register
    user = User.new
    user.name                   = params[:name]
    user.email                  = params[:email]
    user.password               = params[:password]
    user.dob                    = params[:dob]
    user.timezone               = params[:timezone]
    user.tob                    = params[:tob]
    user.gender                 = params[:gender]

    if user.valid?
      if user.save
        return head 201
      else
        render plain: 'System error !', status: 400
      end
    else
      render json: user.errors.messages, status: 400
    end
  end

  def resetPassword
    user = User.find_by_email(params[:email])
    if user.present?
      new_password  = SecureRandom.hex(5)
      user.password               = new_password
      user.token                  = ''
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
    data = Hash.new
    user = User.find_by(email: @user[:email]).try(:authenticate, params[:old_password])
    if user.present?
      # update password
      user.password = params[:password]

      if user.valid?
        if user.save
          # create token
          payload = {id: @user.id, email: @user.email, exp: Time.now.to_i + 24 * 3600}
          token = JWT.encode payload, Settings.hmac_secret, 'HS256'

          # update token
          @user.update(last_login: Time.now, token: token)

          data[:token] = token
          render json: data
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

end