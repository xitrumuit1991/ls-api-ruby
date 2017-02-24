require 'google/api_client'
require 'venice'

class Api::V1::IapController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:get_coins]

  def get_coins
    @coins = Coin.all
  end

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
        return head 500
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
            end
          else
            render json: { error: "Transaction does not exist !" }, status: 400
          end
        else
          render json: { error: "Status error #{json_resp['status']} !" }, status: 400
        end
      else
        render json: { error: "System error !" }, status: 400
      end
    else
      render json: { error: "Vui lòng nhập đầy đủ tham số !" }, status: 400
    end
  end

end