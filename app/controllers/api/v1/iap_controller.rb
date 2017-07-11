require 'google/api_client'
require 'venice'

class Api::V1::IapController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:get_coins]

  def get_coins
    @coins = Coin.all
  end





  def android
    Rails.logger.info('+++++++++++++++IAP android++++++++++++++++')
    Rails.logger.info('+++++++++++++++IAP android++++++++++++++++')
    Rails.logger.info('+++++++++++++++IAP android++++++++++++++++')
    Rails.logger.info("+++++++++++++++packageName   =#{params[:packageName]}")
    Rails.logger.info("+++++++++++++++productId     =#{params[:productId]}")
    Rails.logger.info("+++++++++++++++purchaseToken =#{params[:purchaseToken]}")
    return render json: {message: 'Khong co param packageName',    status_purchase: 0 }, status: 400 if params[:packageName].blank?
    return render json: {message: 'Khong co param productId',      status_purchase: 0 }, status: 400 if params[:productId].blank?
    return render json: {message: 'Khong co param purchaseToken' , status_purchase: 0 }, status: 400 if params[:purchaseToken].blank?
    if params[:packageName].present? && params[:productId].present? && params[:purchaseToken].present?
      coin = Coin.find_by(code: params[:productId])
      return render json: {message: 'Không tìm thấy coin.', detail: "can not find coin from database"}, status: 400 if coin.blank?
      receipt = AndroidReceipt.find_by(orderId: params[:orderId])
      if receipt.present?
        Rails.logger.info("da co receipt; receipt=#{receipt.to_json}")
        return render json: { status_purchase: 1, message: 'da co receipt roi', detail: receipt.to_json }, status: 200 if receipt.status
      else
        Rails.logger.info("create receipt")
        @user.android_receipts.create(orderId: params[:orderId], packageName: params[:packageName], productId: params[:productId], purchaseTime: params[:purchaseTime], purchaseState: params[:purchaseState], purchaseToken: params[:purchaseToken])
      end
      #load file key sign api google
      # key = Google::APIClient::PKCS12.load_key("Livestar-9871dcca72c2.p12", 'notasecret')
      key = Google::APIClient::KeyUtils.load_from_pkcs12("Livestar-9871dcca72c2.p12", 'notasecret')
      Rails.logger.info("----------load key tu file.p12; key=#{key}")
      client = Google::APIClient.new(application_name: 'livestar app', application_version: '1.0.0')
      client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience             => 'https://accounts.google.com/o/oauth2/token',
        :scope                => 'https://www.googleapis.com/auth/androidpublisher',
        :issuer               => 'livestar@api-7360460321031135596-360146.iam.gserviceaccount.com',
        :signing_key          => key
      )
      begin
        client.authorization.fetch_access_token!
        publisher = client.discovered_api('androidpublisher', 'v2')
        Rails.logger.info("CALL API gg to get purchases.products ")
        result = client.execute(
          :api_method => publisher.purchases.products.get,
          :parameters => {'packageName' => params[:packageName], 'productId' => params[:productId], 'token' => params[:purchaseToken]}
        )
        Rails.logger.info("responseFromGG; result=")
        Rails.logger.info(result)
        Rails.logger.info("result.status=#{result.status}")
        Rails.logger.info("result.body=#{result.body}")
        begin
          #result.body is a string, so need parse JSON
          resps = JSON.parse(result.body)
          Rails.logger.info("result.body after parse json; result.body=#{resps}")
          if result.status and result.status.to_i == 200 and resps['error'].blank?
            if resps['purchaseState'].to_i == 0
              money = @user.money.to_i + coin.quantity.to_i
              @user.update(money: money)
              @user.android_receipts.find_by(orderId: params[:orderId]).update(status: true)
            end
            return render json: {  status_purchase: 1,  money: @user.money,  dataOfGG:  {statusHttp: result.status, data: resps }  }, status: 200
          end
          return render json: { 
            status_purchase: 0, 
            message: "Has error from response Google", 
            dataOfGG:  {statusHttp: result.status, data: resps }, 
            errorMessageGG: resps['error']['message'], 
            statusErrorGG: resps['error']['code'].to_i
            }, status: 400

        rescue => errorParseJson
          Rails.logger.info("---------errorParseJson: #{errorParseJson}")
          return render json: {  
            status_purchase: 0, 
            exception: errorParseJson.to_s, 
            message: "can not parse JSON response from google "
            } , status: 400
        end
      rescue => error
        Rails.logger.info("---------Authorization fetch_access_token from our service account fail!")
        Rails.logger.info("---------error: #{error}")
        return render json: {   
          status_purchase: 0,  
          exception: error.to_s,  
          message: "Authorization fetch_access_token from our service account fail!"  
          } , status: 400
      end
    end
  end





  def ios
    # receipt = Venice::Receipt.verify(params[:receipt])
    # puts '==============='
    # puts receipt.to_h
    # puts '==============='
    
    # Itunes.sandbox!
    # receipt = Itunes::Receipt.verify! params[:receipt], :allow_sandbox_receipt
    # puts '==============='
    # puts receipt.inspect
    # puts '==============='

    # check product_id exist
    if params[:receipt].present? && params[:product_id].present?
      coin = Coin.find_by(code: params[:product_id])
      unless coin.present?
        # return head 500
        return render json: {message: 'Không tìm thấy coin.'}, status: 400
      end

      apple_receipt_verify_url = "https://buy.itunes.apple.com/verifyReceipt"
      url = URI.parse(apple_receipt_verify_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      valid = false
      json_request = {'receipt-data' => params[:receipt] }.to_json
      resp = http.post(url.path, json_request, {'Content-Type' => 'application/x-www-form-urlencoded'})
      resp_body = resp
      json_resp = JSON.parse(resp_body.body)

      if resp.code == '200'
        if json_resp['status'] == 0
          current_IAP_receipt = json_resp['receipt']['in_app'].find {|x| x['product_id'] == coin[:code]}
          if current_IAP_receipt.present?
            if IosReceipt.find_by(transaction_id: current_IAP_receipt['transaction_id']).present?
              return head 200
            else
              receipt = {
                quantity: current_IAP_receipt['quantity'],
                product_id: current_IAP_receipt['product_id'],
                transaction_id: current_IAP_receipt['transaction_id'],
                original_transaction_id: current_IAP_receipt['original_transaction_id'],
                purchase_date: current_IAP_receipt['purchase_date'],
                purchase_date_ms: current_IAP_receipt['purchase_date_ms'],
                purchase_date_pst: current_IAP_receipt['purchase_date_pst'],
                original_purchase_date: current_IAP_receipt['original_purchase_date'],
                original_purchase_date_ms: current_IAP_receipt['original_purchase_date_ms'],
                original_purchase_date_pst: current_IAP_receipt['original_purchase_date_pst'],
                is_trial_period: current_IAP_receipt['is_trial_period'],
              }
              @user.ios_receipts.create(receipt)
              # update user coins
              money = @user.money + coin.quantity
              @user.update(money: money)
              return head 200
              return render json: {message: 'OK'}, status: 200
            end
          else
            render json: { message: "Transaction does not exist !" }, status: 400
          end
        else
          render json: { message: "Status error #{json_resp['status']} !" }, status: 400
        end
      else
        render json: { message: "System error !" }, status: 400
      end
    else
      render json: { message: "Vui lòng nhập đầy đủ tham số !" }, status: 400
    end
  end

end