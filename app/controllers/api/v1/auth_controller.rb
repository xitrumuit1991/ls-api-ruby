require 'jwt'

class Api::V1::AuthController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:login, :fbRegister, :gpRegister, :register, :forgotPassword, :verifyToken, :updateForgotCode, :setNewPassword, :check_forgotCode]

  resource_description do
    short 'Authorization'
    formats ['json']
  end

  def login
    @user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
    if @user.present?
      if (Time.now.to_i - @user.last_login.to_i) <= 86400
        @user.increaseExp(20)
      end
      @user.checkVip
      if @user.actived
        # create token
        token = createToken(@user)

        # update token
        @user.update(last_login: Time.now, token: token)

        render json: { token: token }, status: 200
      else
        render json: { error: "Tài khoản này chưa được kích hoạt !" }, status: 401
      end
    else
      render json: { error: "Email hoặc mật khẩu bạn vừa nhập không chính xác !" }, status: 401
    end
  end

  def logout
    @user.update(token: '')
    return head 200
  end

  def register
    activeCode = SecureRandom.hex(3).upcase
    user = User.new
    user.email        = params[:email]
    user.password     = params[:password].to_s
    user.active_code  = activeCode
    if user.valid?
      user.name           = params[:email].split("@")[0].length >= 6 ? params[:email].split("@")[0] : params[:email].split("@")[0] + SecureRandom.hex(3)
      user.username       = params[:email].split("@")[0] + SecureRandom.hex(3).upcase
      user.birthday       = '2000-01-01'
      user.user_level_id  = UserLevel.first().id
      user.money          = 8
      user.user_exp       = 0
      user.actived        = 0
      user.no_heart       = 0
      if user.save
        SendCodeJob.perform_later(user, activeCode)
        render json: { success: "Vui lòng kiểm tra mail để kích hoạt tài khoản của bạn !" }, status: 201
      else
        render json: { error: "System error !" }, status: 500
      end
    else
      render json: { error: user.errors.messages }, status: 400
    end
  end

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
        activeCode              = SecureRandom.hex(3).upcase
        password                = SecureRandom.hex(5)
        user                    = User.new
        user.name               = profile['name'].length >= 6 ? profile['name'] : profile['name'] + SecureRandom.hex(3)
        user.username           = profile['email'].split("@")[0] + SecureRandom.hex(3).upcase
        user.email              = profile['email']
        user.gender             = profile['gender']
        user.birthday           = profile['birthday'].present? ? profile['birthday'] : '2000-01-01'
        user.fb_id              = profile['id']
        user.user_level_id      = UserLevel.first().id
        user.remote_avatar_url  = graph.get_picture(profile['id'], type: :large)
        user.password           = password
        user.active_code        = activeCode
        user.money              = 8
        user.user_exp           = 0
        user.no_heart           = 0
        user.actived            = 1
        user.active_date        = Time.now
        if user.save
          user = User.find_by_email(profile['email'])
          token = createToken(user)
          user.update(last_login: Time.now, token: token)
          render json: { token: token }, status: 200
        else
          render json: { error: user.errors.messages }, status: 400
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

  def updateForgotCode
    user = User.find_by_email(params[:email])
    forgot_code = SecureRandom.hex(4)
    if user.present?
      if user.update(forgot_code: forgot_code)
        UserMailer.confirm_forgot_password(user,forgot_code).deliver_now
        return head 200
      else
        render json: user.errors.messages, status: 400
      end
    else
      return head 404
    end
  end

  def setNewPassword
      user = User.find_by_forgot_code(params[:forgot_code])
      if user.present?
        new_password = SecureRandom.hex(4)
        if user.update(password: new_password, token: '')
          if UserMailer.reset_password(user, new_password).deliver_now
            user.update(forgot_code: SecureRandom.hex(4))
            return head 200
          end
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
      payload = {id: user.id, email: user.email, name: user.name, exp: Time.now.to_i + 24 * 3600}
      token = JWT.encode payload, Settings.hmac_secret, 'HS256'
    end
end