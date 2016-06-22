require 'jwt'

class Api::V1::AuthController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include Api::V1::Vas
  include Api::V1::Wap
  include CaptchaHelper
  include KrakenHelper

  before_action :authenticate, except: [:login, :fbRegister, :gpRegister, :register, :forgotPassword, :verifyToken, :updateForgotCode, :setNewPassword, :check_forgotCode, :mbf_login, :mbf_detection, :mbf_register, :mbf_verify, :mbf_sync, :mbf_register_other, :check_user_mbf, :wap_mbf_register_request, :wap_mbf_register_response]
  before_action :mbf_auth, only: [:mbf_login, :mbf_detection]

  def mbf_login
    token = createToken(@user)
    @user.update(last_login: Time.now, token: token)
    render json: { token: token }, status: 200
  end

  def mbf_detection
    if @user.present?
      token = createToken(@user)
      @user.update(last_login: Time.now, token: token)
      render json: { token: token }, status: 200
    else
      render json: { token: nil }, status: 200
    end
  end

  def mbf_register
    # Trường hợp số điện thoại khác, thì giả lập msisdn bằng params phone
    if params[:phone].present?
      @msisdn = params[:phone]
      if MobifoneUser.where(sub_id: @msisdn).exists?
        @mbf_user = MobifoneUser.find_by_sub_id(@msisdn)
      end
    else
      mbf_auth
    end

    if !@mbf_user.present?
      # generate otp
      otp = SecureRandom.hex(4)
      sms_content = "Sử dụng mã OTP sao để kích hoạt tài khoản của bạn #{otp}";
      send_sms_result = vas_sms @msisdn, sms_content
      if !send_sms_result[:is_error]
        user = User.find_by_phone(@msisdn)
        if user.present?
          if user.otps.find_by_service('mbf').present?
            if user.actived
              user.otps.find_by_service('mbf').update(code: otp)
              render json: { message: "Số điện thoại này đã có trong hệ thống Livestar, bạn có muốn đồng bộ với tài khoản Livestar không ?" }, status: 200
            else
              user.otps.find_by_service('mbf').update(code: otp)
              render json: { message: "Vui lòng nhập mã OTP để kích hoạt tài khoản của bạn !" }, status: 201
            end
          else
            user.otps.create(code: otp, service: 'mbf')
            render json: { message: "Số điện thoại này đã có trong hệ thống Livestar, bạn có muốn đồng bộ với tài khoản Livestar không ?" }, status: 200
          end
        else
          activeCode = SecureRandom.hex(3).upcase
          user = User.new
          user.phone        = @msisdn
          user.email        = "#{@msisdn}@mobifone.com.vn"
          user.password     = @msisdn
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
              user.otps.create(code: otp, service: 'mbf')
              render json: { message: "Vui lòng nhập mã OTP để kích hoạt tài khoản của bạn !" }, status: 201
            else
              render json: { error: "System error !" }, status: 400
            end
          else
            render json: { error: user.errors.full_messages }, status: 400
          end
        end
      else
        render json: { error: "Có lổi xảy ra, bạn đăng ký lại !" }, status: 400
      end
    else
      render json: { error: "Tài khoản này đã được đăng ký !" }, status: 403
    end
  end

  def mbf_verify
    # Trường hợp số điện thoại khác, thì giả lập msisdn bằng params phone
    if params[:phone].present?
      @msisdn = params[:phone]
      if MobifoneUser.where(sub_id: @msisdn).exists?
        @mbf_user = MobifoneUser.find_by_sub_id(@msisdn)
      end
    else
      mbf_auth
    end

    if !@mbf_user.present?
      user = User.find_by_phone(@msisdn)
      if user.present?
        if user.otps.find_by(code: params[:otp], service: 'mbf', used: 0).present?
          register_result = vas_register @msisdn
          # check reuslt
          if !register_result[:is_error]
            # update otp was used
            user.otps.find_by(code: params[:otp], service: 'mbf', used: 0).update(used: 1)
            # create token
            token = createToken(user)
            # update token
            user.update(actived: true, active_date: Time.now, last_login: Time.now, token: token)
            # create mobifone user
            user.create_mobifone_user(sub_id: @msisdn, pkg_code: "VIP", register_channel: "APP", active_date: Time.now, expiry_date: Time.now + 1.days, status: 1)
            # get vip1
            vip1 = VipPackage.find_by(code: 'VIP', no_day: 1)
            if vip1.present?
              # subscribe vip1
              user_has_vip_package = user.user_has_vip_packages.create(vip_package_id: vip1.id, actived: 1, active_date: Time.now, expiry_date: Time.now + 1.days)
              # create mobifone user vip logs
              user.mobifone_user.mobifone_user_vip_logs.create(user_has_vip_package_id: user_has_vip_package.id, pkg_code: "VIP")
              # return token
              render json: { token: token }, status: 200
            else
              render json: { error: "Sytem error !" }, status: 400
            end
          else
            render json: { error: "Có lổi xảy ra, bạn đăng ký lại !" }, status: 400
          end
        else
          render json: { error: "Mã OTP không đúng, vui lòng kiểm tra lại !" }, status: 401
        end
      else
        render json: { error: "Xác nhận OTP không thành công do tài khoản này không tồn tại trong hệ thống !" }, status: 403
      end
    else
      render json: { error: "Tài khoản này đã được đăng ký !" }, status: 403
    end
  end

  def mbf_sync
    # Trường hợp số điện thoại khác, thì giả lập msisdn bằng params phone
    if params[:phone].present?
      @msisdn = params[:phone]
      if MobifoneUser.where(sub_id: @msisdn).exists?
        @mbf_user = MobifoneUser.find_by_sub_id(@msisdn)
      end
    else
      mbf_auth
    end

    if !@mbf_user.present?
      user = User.find_by(phone: @msisdn).try(:authenticate, params[:password])
      if user.present?
        if user.otps.find_by(code: params[:otp], service: 'mbf', used: 0).present?
          register_result = vas_register @msisdn, user.username, params[:password]
          # check result
          if !register_result[:is_error]
            # update otp was used
            user.otps.find_by(code: params[:otp], service: 'mbf', used: 0).update(used: 1)
            # create token
            token = createToken(user)
            # update token
            if user.actived
              user.update(last_login: Time.now, token: token)
            else
              user.update(actived: true, active_date: Time.now, last_login: Time.now, token: token)
            end
            # create mobifone user
            user.create_mobifone_user(sub_id: @msisdn, pkg_code: "VIP", register_channel: "APP", active_date: Time.now, expiry_date: Time.now + 1.days, status: 1)
            # check user has vip packages
            # TODO: Trong trường hợp user đã có gói VIP trước đó thì xử lý thế nào?
            # vì nếu không báo gì cho VAS thì họ gia hạn gói hằng ngày như thế nào, biết charge tiền ra sao?
            if !user.user_has_vip_packages.find_by_actived(1).present?
              # get vip1
              vip1 = VipPackage.find_by(code: 'VIP', no_day: 1)
              if vip1.present?
                # subscribe vip1
                user_has_vip_package = user.user_has_vip_packages.create(vip_package_id: vip1.id, actived: 1, active_date: Time.now, expiry_date: Time.now + 1.days)
                # create mobifone user vip logs
                user.mobifone_user.mobifone_user_vip_logs.create(user_has_vip_package_id: user_has_vip_package.id, pkg_code: "VIP")
              else
                render json: { error: "Sytem error !" }, status: 400    
              end
            end
            # return token
            render json: { token: token }, status: 200
          else
            render json: { error: "Có lổi xảy ra, bạn hãy thử đăng nhập lại !" }, status: 400
          end
        else
          render json: { error: "Mã OTP không đúng, vui lòng kiểm tra lại !" }, status: 401
        end
      else
        render json: { error: "Mật khẩu không đúng xin hãy thử lại !" }, status: 401
      end
    else
      render json: { error: "Tài khoản này đã được đăng ký !" }, status: 403
    end
  end

  def check_user_mbf
    user =  User.find_by(phone: params[:phone])
    if user.present?
      if user.mobifone_user.present?
        return head 200
      else
        render json: { error: "Xin lỗi, số điện thoại này chưa đăng ký tài khoản Mobifone, bạn vui lòng kiểm tra lại !" }, status: 404
      end
    else
      render json: { error: "Số điện thoại này không tồn tại trong hệ thống Livestar !" }, status: 404
    end
  end

  def wap_mbf_register_request
    sp_id       = 140
    trans_id    = SecureRandom.hex(8)
    pkg         = "VIP7"
    price       = 0
    back_url    = "#{Settings.m_livestar_path}/user-mbf-result"
    information = "String 1||String 2"

    # insert wap mbf logs
    WapMbfLog.create(sp_id: sp_id, trans_id: trans_id, pkg: pkg, price: price, information: information)
    # encrypt data
    data = "#{trans_id}&#{pkg}&#{price}&#{back_url}&#{information}"
    link = encrypt data
    redirect_to "#{Settings.wap_register_url}?sp_id=#{sp_id}&link=#{link}" and return
    # redirect_to "#{Settings.wap_register_url}?sp_id=#{sp_id}&link=DFYsKBDB9u3uGOOzptM/WdcWVRo9wk+G8ePpRRviZicw8p43i7y6ssigMfI8VBlDGhD9C5rwzSn6TVlEPXQeuwP7vp1G11tKtttx4Q7qzRDLbhNjPXNwOvSS0iLYZLM0" and return
  end

  def wap_mbf_register_response
    # decypt data
    data = decrypt params[:data]
    data = data.split("&")
    # check status
    if data[2] == 1
      msisdn = data[1]
      # call api vas register
      charge_result = vas_register msisdn
      if !charge_result[:is_error]
        # create user
        activeCode = SecureRandom.hex(3).upcase
        user = User.new
        user.phone        = msisdn
        user.email        = "#{msisdn}@mobifone.com.vn"
        user.password     = msisdn
        user.active_code  = activeCode
        if user.valid?
          user.name           = msisdn
          user.username       = msisdn
          user.birthday       = '2000-01-01'
          user.user_level_id  = UserLevel.first().id
          user.money          = 8
          user.user_exp       = 0
          user.no_heart       = 0
          user.actived        = true
          user.active_date    = Time.now
          if user.save
            # find log
            wap_mbf_log = WapMbfLog.find_by(trans_id: data[0])
            # update log
            wap_mbf_log.update(msisdn: data[1], status: data[2])
            # get vip1
            vip1 = VipPackage.find_by(code: 'VIP', no_day: 1)
            # subscribe vip1
            user_has_vip_package = user.user_has_vip_packages.create(vip_package_id: vip1.id, actived: 1, active_date: Time.now, expiry_date: Time.now + 1.days)
            # create mobifone user vip logs
            user.mobifone_user.mobifone_user_vip_logs.create(user_has_vip_package_id: user_has_vip_package.id, pkg_code: "VIP")
            # add bonus coins for user
            money = user.money + vip1.discount
            user.update(money: money)
            render json: { status: data[2] }, status: 200
          else
            render json: { error: "System error !" }, status: 400
          end
        else
          render json: { error: user.errors.full_messages }, status: 400
        end
      else
        render json: { error: "Vas error !" }, status: 400
      end
    else
      # find log
      wap_mbf_log = WapMbfLog.find_by(trans_id: data[0])
      # update log
      wap_mbf_log.update(msisdn: data[1], status: data[2])
      render json: { status: data[2] }, status: 200
    end
  end

  def login
    if params[:email] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
      @user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
      @user_attempt = User.find_by(email: params[:email])
    else
      phone = "84#{params[:email][1..-1]}"
      @user = User.find_by(phone: phone).try(:authenticate, params[:password])
      @user_attempt = User.find_by(phone: phone)
    end

    if @user_attempt.present?
        if @user_attempt.is_locking
          render json: { error: "Tài khoản này đã bị khoá do đăng nhập sai quá 4 lần, xin vui lòng thử lại sau 10 phút" }, status: 401 and return
        end
    end

    if @user.present?
      if (Time.now.to_i - @user.last_login.to_i) <= 86400
        @user.increaseExp(20)
      end
      if @user.actived
        # create token
        token = createToken(@user)

        # update token
        @user.update(failed_attempts: 0, locked_at: nil,last_login: Time.now, token: token)

        render json: { token: token }, status: 200
      else
        render json: { error: "Tài khoản này chưa được kích hoạt !" }, status: 401
      end
    else
      if @user_attempt.present?
        @user_attempt.login_fail
        render json: { error: "Đăng nhập không thành công lần thứ #{@user_attempt.failed_attempts}/5 xin hãy thử lại !" }, status: 401
      else
        render json: { error: "Đăng nhập không thành công xin hãy thử lại !" }, status: 401
      end
    end
  end

  def logout
    @user.update(token: '')
    return head 200
  end

  def register
    activeCode = SecureRandom.hex(3).upcase
    if params[:email].present? &&  params[:password].present?
      # checkCaptcha = eval(checkCaptcha(params[:key_register]))
      if true
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
          render json: {error: t('error_system') , bugs: user.errors.full_messages}, status: 400
        end
      else
        render json: {error: "Vui lòng kiểm tra Captcha" }, status: 400
      end
    else
      render json: {error: "Vui lòng kiểm tra Captcha" }, status: 400
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
        user.remote_avatar_url      = graph.get_picture(profile['id'], type: :large)
        user.remote_avatar_crop_url = uploadDowload(graph.get_picture(profile['id'], type: :large))
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
    rescue RestClient::Exception
      return head 401
    end
  end

  def verifyToken
    user = User.find_by(email: params[:email], token: params[:token])
    if user.present?
      begin
        JWT.decode params[:token], Settings.hmac_secret
        return head 200
      rescue JWT::ExpiredSignature
        return head 400
      end
    else
      begin
        JWT.decode params[:token], Settings.hmac_secret
        return head 200
      rescue Exception
        render json: {error: e.message}, status: 400
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
    def mbf_auth
      render json: { error: "Request not from Mobifone 3G" }, status: 403 and return if !check_mbf_auth
    end

    def createToken(user)
      payload = {id: user.id, email: user.email, name: user.name, vip: user.vip, exp: Time.now.to_i + 24 * 3600}
      JWT.encode payload, Settings.hmac_secret, 'HS256'
    end
end