arequire 'jwt'
require 'ipaddr'

module Api::V1::Authorize extend ActiveSupport::Concern

  def authenticate
    authenticate_token || render_unauthorized
  end

  def check_authenticate
    authenticate_with_http_token do |token, options|
      begin
        JWT.decode token, Settings.hmac_secret, true
        return User.find_by(token: token)
      rescue
        return nil
      end
    end
  end

  def check_mbf_auth
    if request.headers['HTTP_MSISDN'].present? and request.headers['HTTP_X_FORWARDED_FOR'].present?
      begin
        ip = request.headers['HTTP_X_FORWARDED_FOR'].scan /\d+\.\d+\.\d+\.\d+/
        if scan_ip ip[0]
          @msisdn = request.headers['HTTP_MSISDN']
          if MobifoneUser.where(sub_id: @msisdn).exists?
            @mbf_user = MobifoneUser.find_by_sub_id(@msisdn)
            @user = @mbf_user.user
          end
          return true
        end
      rescue
        return false
      end
    end
    return false
  end

  private
    def authenticate_token
      authenticate_with_http_token do |token, options|
        begin
          decoded_token = JWT.decode token, Settings.hmac_secret, true
          @token_user = decoded_token[0]
          @user = User.find_by(token: token)
        rescue
          return head 401
        end
      end
    end

    def render_unauthorized
      self.headers['WWW-Authenticate'] = 'Token realm="Application"'
      return head 401
    end

    def scan_ip(ip)
      ips = MobifoneIp.all
      return false if !ips.present?
      begin
        ips.each do |e|
          list_ips = IPAddr.new(e.ip)
          user_ip = IPAddr.new(ip)
          if list_ips.include?(user_ip)
            return true
          end
        end
        return false
      rescue => ex # or rescue Exception
        return false
      end
    end



end