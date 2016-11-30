require 'digest/md5'

module Api::V1::Mbuy extend ActiveSupport::Concern

  def create_cp_transaction isdn, total_amount
    begin
      client = Savon.client(wsdl: Settings.mbuy_wsdl)

      transaction = Time.now.to_i.to_s
      payload = "#{isdn}#{Settings.content_id}#{total_amount}#{Settings.service_name}#{Settings.cp_id}#{Settings.user_name}#{Settings.password}#{transaction}"
      checksum = Digest::MD5.hexdigest("#{payload}#{payload.length}")

      message = {
        arg0: isdn.to_s, 
        arg1: Settings.content_id, 
        arg2: total_amount.to_s, 
        arg3: Settings.service_name, 
        arg4: Settings.cp_id, 
        arg5: Settings.user_name, 
        arg6: Settings.password, 
        arg7: transaction, 
        arg8: checksum 
      }

      response = client.call(:create_cp_transaction, message: message)
      reponse_body = response.body[:create_cp_transaction_response][:return]
      result = reponse_body.split('|')
      
      MbuyTransaction.create(trans_id: transaction, trans_code: result[1], isdn: isdn, total_amount: total_amount, checksum: checksum, user_id: @user.id, response: reponse_body, status: 0)

      reponse_body
    rescue Savon::SOAPFault
      return {is_error: true, message: 'System error!'}
    end
  end

end