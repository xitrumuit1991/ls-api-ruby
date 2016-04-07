require 'jwt'

class Api::V1::AuthController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:login, :fbRegister, :gpRegister, :register, :forgotPassword, :verifyToken, :updateForgotCode, :setNewPassword, :check_forgotCode, :mbf_login, :mbf_detection, :mbf_register, :mbf_verify]

  resource_description do
    short 'Authorization'
    formats ['json']
  end

  def mbf_login
    if check_mbf_auth
      render plain: @msisdn, status: 200 and return
    end
    return head 401
  end

  def mbf_detection
    if check_mbf_auth
      render json: { phone: @msisdn }, status: 200 and return
    end
    render json: { error: "Request not from Mobifone 3G !" }, status: 403
  end

  def mbf_register
    if check_mbf_auth
      if !defined? @mbf_user
        user = User.find_by_phone(@msisdn)
        if user.present?
          if user.otps.find_by_service('mbf').present?
            user.otps.find_by_service('mbf').update(code: '222')
            render json: { message: "Vui lòng nhập mã OTP để kích hoạt tài khoản của bạn !" }, status: 201 and return
          else
            render json: { message: "Số điện thoại này đã có trong hệ thống Livestar, bạn có muốn đồng bộ với tài khoản Livestar không ?" }, status: 200 and return
          end
        else
          activeCode = SecureRandom.hex(3).upcase
          password   = SecureRandom.hex(5)
          user = User.new
          user.phone        = @msisdn
          user.email        = "#{@msisdn}@email.com"
          user.password     = password
          user.active_code  = activeCode
          if user.valid?
            user.name           = @msisdn
            user.username       = @msisdn
            user.birthday       = '2000-01-01'
            user.user_level_id  = UserLevel.first().id
            user.money          = 8
            user.user_exp       = 0
            user.actived        = 0
            user.no_heart       = 0
            if user.save
              user.otps.create(code: '111', service: 'mbf')
              render json: { message: "Vui lòng nhập mã OTP để kích hoạt tài khoản của bạn !" }, status: 201 and return
            else
              render json: { error: "System error !" }, status: 500 and return
            end
          else
            render json: { error: user.errors.full_messages }, status: 400 and return
          end
        end
      else
        render json: { error: "Tài khoản này đã được đăng ký !" }, status: 400 and return
      end
    end
    render json: { error: "Request not from Mobifone 3G !" }, status: 403
  end

  def mbf_verify
    if check_mbf_auth
      if !defined? @mbf_user
        user = User.find_by_phone(@msisdn)
        if user.present?
          if user.otps.find_by(code: params[:otp], service: 'mbf', used: 0).present?
            # call api register of VAS
            soapClient = Savon.client(wsdl: Settings.vas_url)
            result = soapClient.call(:Register,  message: { phone_number: @msisdn, password: params[:password].to_s, pkg_code: 'VIP', channel: 'APP', username: @msisdn, partner_id: 'DEFAULT' })
            puts '================'
            puts result
            puts '================'

            # update otp was used
            user.otps.find_by(code: params[:otp], service: 'mbf', used: 0).update(used: 1)
            # create token
            token = createToken(user)
            # update token
            user.update(actived: true, active_date: Time.now, last_login: Time.now, token: token)
            # create mobifone user
            user.create_mobifone_user(sub_id: @msisdn, active_date: Time.now, expiry_date: Time.now + 1.days, status: 1)
            # get vip1
            vip1 = VipPackage.find_by(code: 'VIP', no_day: 1)
            if vip1.present?
              # subscribe vip1
              user.user_has_vip_packages.create(vip_package_id: vip1.id, actived: 1, active_date: Time.now, expiry_date: Time.now + 1.days)
              # create trade logs
              user.trade_logs.create(vip_package_id: vip1.id, status: 1)
              # return token
              render json: { token: token }, status: 200 and return
            else
              render json: { error: "Sytem error !" }, status: 400 and return    
            end
          else
            render json: { error: "Mã OTP không đúng, vui lòng kiểm tra lại !" }, status: 400 and return  
          end
        else
          render json: { error: "Xác nhận OTP không thành công do tài khoản này không tồn tại trong hệ thống !" }, status: 400 and return
        end
      else
        render json: { error: "Tài khoản này đã được đăng ký !" }, status: 400 and return
      end
    end
    render json: { error: "Request not from Mobifone 3G !" }, status: 403
  end

  def mbf_sync
    if check_mbf_auth
      if !defined? @mbf_user
        user = User.find_by(phone: @msisdn).try(:authenticate, params[:password])
        if user.present?
          # call api register of VAS
          soapClient = Savon.client(wsdl: Settings.vas_url)
          result = soapClient.call(:Register,  message: { phone_number: @msisdn, password: params[:password].to_s, pkg_code: 'VIP', channel: 'APP', username: @msisdn, partner_id: 'DEFAULT' })

          # create token
          token = createToken(user)
          # update token
          user.update(last_login: Time.now, token: token)
          # create mobifone user
          user.create_mobifone_user(sub_id: @msisdn, active_date: Time.now, expiry_date: Time.now + 1.days, status: 1)          
          # check user has vip packages
          if !user.user_has_vip_packages.find_by_actived(1).present?
            # get vip1
            vip1 = VipPackage.find_by(code: 'VIP', no_day: 1)
            if vip1.present?
              # subscribe vip1
              user.user_has_vip_packages.create(vip_package_id: vip1.id, actived: 1, active_date: Time.now, expiry_date: Time.now + 1.days)
              # create trade logs
              user.trade_logs.create(vip_package_id: vip1.id, status: 1)
            else
              render json: { error: "Sytem error !" }, status: 400 and return    
            end
          end
          # return token
          render json: { token: token }, status: 200 and return
        else
          render json: { error: "Đăng nhập không thành công xin hãy thử lại !" }, status: 401 and return
        end
      else
        render json: { error: "Tài khoản này đã được đăng ký !" }, status: 400 and return
      end
    end
    render json: { error: "Request not from Mobifone 3G !" }, status: 403
  end

  def login
    if params[:email] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
      @user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
    else
      phone = "84#{params[:email][1..-1]}"
      @user = User.find_by(phone: phone).try(:authenticate, params[:password])
    end

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
      render json: { error: "Đăng nhập không thành công xin hãy thử lại !" }, status: 401
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
          render json: {error: e.message}, status: 400
        end
      else
        render json: {error: 'User không tồn tại!'}, status: 401
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
        render json: {error:  t('error'), bugs: user.errors.full_messages}, status: 400
      end
    else
      render json: {error: 'Email không tồn tại, vui lòng nhập lại nhé!'}, status: 404
    end
  end

  def setNewPassword
      user = User.find_by_forgot_code(params[:forgot_code])
      if user.present?
        new_password = SecureRandom.hex(4)
        if user.update(password: new_password, token: '')
          if UserMailer.reset_password(user, new_password).deliver_now
            if !user.actived
              user.actived = 1
            end
            user.forgot_code = SecureRandom.hex(4)
            if user.save
              return head 200
            else
              render json: {error: t('error'), bugs: user.errors.full_messages}, status: 400
            end
          end
        else
          render json: {error: t('error'), bugs: user.errors.full_messages}, status: 400
        end
      else
        render json: {error: 'Mã code không tồn tại, vui lòng nhập lại nhé!'}, status: 404
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
          render json: {error: t('error_system')}, status: 400
        end
      else
        render json: {error: t('error'), bugs: user.errors.full_messages}, status: 400
      end
    else
      render json: {error: 'Vui lòng đăng nhập lại để sử dụng'}, status: 401
    end
  end

  private
    def createToken(user)
      payload = {id: user.id, email: user.email, name: user.name, exp: Time.now.to_i + 24 * 3600}
      token = JWT.encode payload, Settings.hmac_secret, 'HS256'
    end
end