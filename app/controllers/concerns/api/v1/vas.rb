module Api::V1::Vas extend ActiveSupport::Concern

  def vas_sms phone, content
    begin
      # call VAS webservice
      soapClient = Savon.client do |variable|
        variable.proxy Settings.vas_proxy
        variable.wsdl Settings.vas_wsdl
      end
      # params request
      message = {
        "tns:sender"      => "9387",
        "tns:receiver"    => phone.to_s,
        "tns:sms_content" => content,
        "tns:pkg_id"      => 0,
        "tns:channel"     => "APP"
      }
      # call api send sms
      send_sms_response = soapClient.call(:send_sms, message: message)
      # get response
      send_sms_response.body[:send_sms_response][:send_sms_result]
    rescue Savon::SOAPFault
      return {is_error: true, message: 'System error!'}
    end
  end

  def vas_register phone, pkg_code = "VIP", username = nil, password = nil
    begin
      # call VAS webservice
      soapClient = Savon.client do |variable|
        variable.proxy Settings.vas_proxy
        variable.wsdl Settings.vas_wsdl
      end
      # params request
      message = {
        "tns:phone_number"  => phone.to_s,
        "tns:password"      => password.present? ? password.to_s : phone.to_s,
        "tns:pkg_code"      => pkg_code,
        "tns:channel"       => "APP",
        "tns:username"      => username.present? ? username.to_s : phone.to_s,
        "tns:partner_id"    => "DEFAULT",
      }
      register_response = soapClient.call(:register, message: message)
      register_response.body[:register_response][:register_result]
    rescue Savon::SOAPFault
      return {is_error: true, message: 'System error!'}
    end
  end

  def vas_charge phone_number, money, pkg_id, charge_cmd, request_channel, info
    begin
      # call VAS webservice
      soapClient = Savon.client do |variable|
        variable.proxy Settings.vas_proxy
        variable.wsdl Settings.vas_wsdl
      end
      # params request
      message = {
        "tns:phone_number"      => phone_number,
        "tns:money"             => money, # 2000, 5000, 10000, 20000, 30000, 50000
        "tns:pkg_id"            => pkg_id,
        "tns:charge_cmd"        => charge_cmd, # DANG_KY = 0, GIA_HAN = 1, MUA_XU=3, TANG_XU=4
        "tns:request_channel"   => request_channel, # WEB/APP/WAP
        "tns:info"              => info
      }
      charge_response = soapClient.call(:charge, message: message)
      charge_response.body[:charge_response][:charge_result]
    rescue Savon::SOAPFault
      return {is_error: true, message: 'System error!'}
    end
  end

end