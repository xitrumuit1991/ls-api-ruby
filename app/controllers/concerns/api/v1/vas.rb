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
      send_sms_response = soapClient.call(:send_sms,  message: message)
      # get response
      send_sms_response.body[:send_sms_response][:send_sms_result]
    rescue Savon::SOAPFault
      return {is_error: true, message: 'System error!'}
    end
  end

  def vas_register phone, username = nil, password = nil
    begin
      # call VAS webservice
      soapClient = Savon.client do |variable|
        variable.proxy Settings.vas_proxy
        variable.wsdl Settings.vas_wsdl
      end
      # params request
      message = {
        "tns:phone_number"  => phone.to_s,
        "tns:password"      => password.nil? ? password.to_s : phone.to_s,
        "tns:pkg_code"      => "VIP",
        "tns:channel"       => "APP",
        "tns:username"      => username.nil? ? username.to_s : phone.to_s,
        "tns:partner_id"    => "DEFAULT"
      }
      register_response = soapClient.call(:register,  message: message)
      register_response.body[:register_response][:register_result]
    rescue Savon::SOAPFault
      return {is_error: true, message: 'System error!'}
    end
  end
end