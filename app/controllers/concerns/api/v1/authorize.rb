require 'jwt'

module Api::V1::Authorize extend ActiveSupport::Concern

  def authenticate
    authenticate_token || render_unauthorized
  end

  def check_authenticate
    authenticate_with_http_token do |token, options|
      begin
        decoded_token = JWT.decode token, Settings.hmac_secret, true
        return User.find_by(token: token)
      rescue => ex # or rescue Exception
        return nil
      end
    end
  end

  def check_mbf_auth
    if request.headers['HTTP_MSISDN'].present? and request.headers['HTTP_X_FORWARDED_FOR'].present?
      ip = request.headers['HTTP_X_FORWARDED_FOR']
      if scan_ip ip
        @msisdn = request.headers['HTTP_MSISDN']
        if MobifoneUser.where(SubID: @msisdn).exists?
          # TODO return User if exist
          @mbf_user = MobifoneUser.find_by_SubID(@msisdn)
        end
        return true
      end
    end
    return false
  end

  private
    def authenticate_token
      authenticate_with_http_token do |token, options|
        begin
          decoded_token = JWT.decode token, Settings.hmac_secret, true
          @user = User.find_by(token: token)
          @user.checkVip
        rescue => ex # or rescue Exception
          return head 401
        end
      end
    end

    def render_unauthorized
      self.headers['WWW-Authenticate'] = 'Token realm="Application"'
      return head 401
    end

    def scan_ip(ip)
      # TODO
      return true
    end

end