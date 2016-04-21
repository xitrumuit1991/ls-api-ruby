require 'google/api_client'

class Api::V1::IapController < Api::V1::ApplicationController
  include Api::V1::Authorize

  def android
    if params[:packageName].present? && params[:productId].present? && params[:purchaseToken].present?
      receipt = AndroidReceipt.find_by(orderId: params[:orderId])
      if receipt.present?
        if receipt.status
          render json: { status_purchase: 1 }, status: 200 and return
        end
      end

      coin = Coin.find_by(code: params[:productId])
      unless coin.present?
        return head 500
      end
      
      # uri = URI("https://www.googleapis.com/androidpublisher/v2/applications/#{params[:packageName]}/purchases/products/#{params[:productId]}/tokens/#{params[:purchaseToken]}")
      # res = Net::HTTP.get_response(uri)
      # result = JSON.parse(res.body)

      # url = URI.parse("https://www.googleapis.com/androidpublisher/v2/applications/#{params[:packageName]}/purchases/products/#{params[:productId]}/tokens/#{params[:purchaseToken]}")
      # req = Net::HTTP::Get.new(url.path)
      # req.add_field("Authorization", "Bearer ya29..ywLbU6W45LlWz9MvNE_5WJ4HnxDR5qPm257FHR7HhmRyJ4gnkpwFUNLyAUR2na4w4g")
      # res = Net::HTTP.start(url.host, url.port, :use_ssl => uri.scheme == 'https') do |http|
      #   http.request(req)
      # end
      # result = JSON.parse(res.body)


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
      data = JSON.parse(result.data.to_json)


      puts '==============='
      puts data
      puts '==============='
      
      render json: data, status: 200
      

      # if !result['error'].present?
      #   unless result['consumptionState'] && result['purchaseState']
      #     money = @user.money + coin.quantity
      #     @user.update(money: money)
      #     @user.coin_logs.create(coin_id: coin.id)
      #     @user.android_receipts.create(orderId: params[:orderId], packageName: params[:packageName], productId: params[:productId], purchaseTime: params[:purchaseTime], purchaseState: params[:purchaseState], purchaseToken: params[:purchaseToken], status: true)
      #   end
      #   render json: { status_purchase: 1 }, status: 200
      # else
      #   render json: { status_purchase: 0 }, status: 200
      #   # render json: { error: result['error']['message'] }, status: result['error']['code'].to_i
      # end
    else
      render json: { error: "Vui lòng nhập đầy đủ tham số !" }, status: 403
    end
  end

  def ios
    
  end

end