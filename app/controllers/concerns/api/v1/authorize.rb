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

end