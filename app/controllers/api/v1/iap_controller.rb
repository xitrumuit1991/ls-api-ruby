require 'google/api_client'

class Api::V1::IapController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, only: [:android]

  def android
    if params[:packageName].present? && params[:productId].present? && params[:purchaseToken].present?
      coin = Coin.find_by(code: params[:productId])
      unless coin.present?
        return head 500
      end

      receipt = AndroidReceipt.find_by(orderId: params[:orderId])
      if receipt.present?
        if receipt.status
          render json: { status_purchase: 1 }, status: 200 and return
        end
      else
        @user.android_receipts.create(orderId: params[:orderId], packageName: params[:packageName], productId: params[:productId], purchaseTime: params[:purchaseTime], purchaseState: params[:purchaseState], purchaseToken: params[:purchaseToken])
      end

      # key = OpenSSL::PKey::RSA.new "#{Rails.root}/config/Livestar-e785257ee406.p12", 'notasecret'
      # key = Google::APIClient::KeyUtils.load_from_pkcs12("#{Rails.root}/config/Livestar-e785257ee406.p12", 'notasecret')
      # key = Google::APIClient::KeyUtils.load_from_pkcs12(Rails.root.join('config','Livestar-e785257ee406.p12').to_s, 'notasecret')
      key = Google::APIClient::PKCS12.load_key("Livestar-e785257ee406.p12", 'notasecret')
      client  = Google::APIClient.new

      client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience             => 'https://accounts.google.com/o/oauth2/token',
        :scope                => 'https://www.googleapis.com/auth/androidpublisher',
        :issuer               => 'in-app-purchase@livestar-cf319.iam.gserviceaccount.com',
        :signing_key          => key
      ).tap { |auth| auth.fetch_access_token! }

      publisher = client.discovered_api('androidpublisher', 'v2')

      # Make the API call
      result = client.execute(
        :api_method => publisher.purchases.products.get,
        :parameters => {'packageName' => params[:packageName], 'productId' => params[:productId], 'token' => params[:purchaseToken]}
      )
      resps = JSON.parse(result.data.to_json)

      if !resps['error'].present?
        if resps['purchaseState'].to_i == 0
          money = @user.money + coin.quantity
          @user.update(money: money)
          @user.android_receipts.find_by(orderId: params[:orderId]).update(status: true)
        end
        render json: { status_purchase: 1 }, status: 200
      else
        render json: { status_purchase: 0 }, status: 200
        # render json: { error: resps['error']['message'] }, status: resps['error']['code'].to_i
      end
    else
      render json: { error: "Vui lòng nhập đầy đủ tham số !" }, status: 403
    end
  end

  def ios
    
  end

end