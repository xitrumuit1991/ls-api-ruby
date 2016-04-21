require 'rest-client'
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
      
      uri = URI("https://www.googleapis.com/androidpublisher/v2/applications/#{params[:packageName]}/purchases/products/#{params[:productId]}/tokens/#{params[:purchaseToken]}")
      # res = Net::HTTP.get_response(uri)
      # result = JSON.parse(res.body)

      # res = RestClient::Request.execute(
      #    :method => :get,
      #    :content_type => :json,
      #    :accept => :json,
      #    :url => "https://www.googleapis.com/androidpublisher/v2/applications/#{params[:packageName]}/purchases/products/#{params[:productId]}/tokens/#{params[:purchaseToken]}",
      #    :headers => {'Authorization' => "Bearer ya29..ywLbU6W45LlWz9MvNE_5WJ4HnxDR5qPm257FHR7HhmRyJ4gnkpwFUNLyAUR2na4w4g"}
      # )
      # result = JSON.parse(res)

      # req = Net::HTTP::Get.new(uri)
      # req.add_field("Authorization", "Bearer ya29..ywLbU6W45LlWz9MvNE_5WJ4HnxDR5qPm257FHR7HhmRyJ4gnkpwFUNLyAUR2na4w4g")
      # res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      #   http.request(req)
      # end

      url = URI.parse("https://www.googleapis.com/androidpublisher/v2/applications/#{params[:packageName]}/purchases/products/#{params[:productId]}/tokens/#{params[:purchaseToken]}")
      req = Net::HTTP::Get.new(url.path)
      req.add_field("Authorization", "Bearer ya29..ywLbU6W45LlWz9MvNE_5WJ4HnxDR5qPm257FHR7HhmRyJ4gnkpwFUNLyAUR2na4w4g")
      res = Net::HTTP.start(url.host, url.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
      end

      result = JSON.parse(res.body)

      puts '==============='
      puts result
      puts '==============='
      if !result['error'].present?
        unless result['consumptionState'] && result['purchaseState']
          money = @user.money + coin.quantity
          @user.update(money: money)
          @user.coin_logs.create(coin_id: coin.id)
          @user.android_receipts.create(orderId: params[:orderId], packageName: params[:packageName], productId: params[:productId], purchaseTime: params[:purchaseTime], purchaseState: params[:purchaseState], purchaseToken: params[:purchaseToken], status: true)
        end
        render json: { status_purchase: 1 }, status: 200
      else
        render json: { status_purchase: 0 }, status: 200
        # render json: { error: result['error']['message'] }, status: result['error']['code'].to_i
      end
    else
      render json: { error: "Vui lòng nhập đầy đủ tham số !" }, status: 403
    end
  end

  def ios
    
  end

end