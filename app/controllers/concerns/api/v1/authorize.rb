require 'jwt'
require 'ipaddr'

module Api::V1::Authorize extend ActiveSupport::Concern

  def authenticate
    authenticate_token || render_unauthorized
  end

  def check_blacklist(sub_id)
    return Rails.cache.fetch("black_list").include?(sub_id)
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
    msisdn = nil
    if request.headers
      msisdn = request.headers['HTTP_MSISDN']
      Rails.logger.info('+++++++++++++++auto login 3g ++++++++++++++++')
      Rails.logger.info('+++++++++++++++auto login 3g ++++++++++++++++')
      Rails.logger.info('+++++++++++++++auto login 3g ++++++++++++++++')
      Rails.logger.info('msisdn=',msisdn)
    end
    return false if msisdn.blank?
    if msisdn.present?
      begin
        @msisdn = msisdn
        if MobifoneUser.where(sub_id: @msisdn).exists?
          @mbf_user = MobifoneUser.find_by_sub_id(@msisdn)
          Rails.logger.info('@mbf_user=#{@mbf_user.to_json}')
          @user = @mbf_user.user
          Rails.logger.info('@user=#{@user.to_json}')
        end
        return true
      rescue
        return false
      end
    end
  end

  private
    def authenticate_token
      authenticate_with_http_token do |token, options|
        begin
          decoded_token = JWT.decode token, Settings.hmac_secret, true
          @token_user = decoded_token[0]
          @user = User.find_by(token: token)
        rescue
          # return head 401
          return render json: {message: 'Invalid token', detail: 'JWT.decode error'}, status: 403
        end
      end
    end

    def render_unauthorized
      self.headers['WWW-Authenticate'] = 'Token realm="Token is invalid"'
      return render json: {message: 'Invalid token'}, status: 403
      # return head 401
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