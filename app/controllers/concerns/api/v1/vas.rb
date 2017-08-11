module Api::V1::Vas extend ActiveSupport::Concern

  def vas_sms phone, content
    begin
      return {is_error: true, message: 'Không có phone hay content!', error: 'vas_sms missing params phone or content'} if !phone or !content
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
      Rails.logger.error("Api::V1::Vas; message=")
      Rails.logger.error(message)
      # call api send sms
      send_sms_response = soapClient.call(:send_sms, message: message)
      # get response
      Rails.logger.error("send_sms_response=")
      Rails.logger.error(send_sms_response)
      send_sms_response.body[:send_sms_response][:send_sms_result]

    rescue Savon::InvalidResponseError
      Logger.log "Invalid server response"
      return {is_error: true, message: 'Có lỗi khi gọi SOAP Service!', error: 'Invalid server response'}

    rescue Savon::HTTPError => error
      Rails.logger.error("Savon::HTTPError=")
      Rails.logger.error("error=#{error}")
      Rails.logger.error("error.http=#{error.http}")
      Rails.logger.error("error.http.code=#{error.http.code}")
      return {is_error: true, message: 'Có lỗi khi gọi SOAP Service!', error: error}

    rescue Savon::SOAPFault => error
      Rails.logger.error("Savon::SOAPFault=")
      Rails.logger.error(error)
      Rails.logger.error(error.http)
      Rails.logger.error(error.http.code)
      return {is_error: true, message: 'Có lỗi khi gọi SOAP Service!', error: error}
    end
  end

  def vas_register phone, pkg_code = "VIP", channel = "APP", partner_id = "DEFAULT", username = nil, password = nil
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
        "tns:channel"       => channel,
        "tns:username"      => username.present? ? username.to_s : phone.to_s,
        "tns:partner_id"    => partner_id,
      }
      register_response = soapClient.call(:register, message: message)
      register_response.body[:register_response][:register_result]
    rescue Savon::SOAPFault
      waplogger = Logger.new("#{Rails.root}/log/vas_register.log")
      waplogger.info("khong dang ky duoc")
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

  def vas_update_partner_report msisdn, partner_id, pkg_code = "VIP", option = 0
    begin
      # call VAS webservice
      soapClient = Savon.client do |variable|
        variable.proxy Settings.vas_proxy
        variable.wsdl Settings.vas_wsdl
      end
      
      # params request
      message = {
        "tns:msisdn"      => msisdn.to_s,
        "tns:partner_id"  => partner_id,
        "tns:pkg_code"    => pkg_code,
        "tns:option"      => option
      }

      response = soapClient.call(:update_partner_report, message: message)
      response.body[:update_partner_report_response][:update_partner_report_result]
      
      $redis.incr("vas:publisher:count:total:#{Time.now.strftime('%Y%m%d')}")
      $redis.incr("vas:publisher:count:#{partner_id}:#{Time.now.strftime('%Y%m%d')}")
    rescue Savon::SOAPFault
      return {is_error: true, message: 'System error!'}
    end
  end

  def vas_cancel_service phone_number, pkg_code, channel, username, sms_option = 1
    begin
      # call VAS webservice
      soapClient = Savon.client do |variable|
        variable.proxy Settings.vas_proxy
        variable.wsdl Settings.vas_wsdl
      end
      # params request
      message = {
        "tns:phone_number"  => phone_number,
        "tns:pkg_code"      => pkg_code,
        "tns:channel"       => channel,
        "tns:username"      => username,
        "tns:sms_option"    => sms_option
      }
      response = soapClient.call(:cancel_service, message: message)
      response.body[:cancel_service_response][:cancel_service_result]
    rescue Savon::SOAPFault
      waplogger = Logger.new("#{Rails.root}/log/vas.log")
      waplogger.error("vas_cancel_service #{phone_number}, #{pkg_code}, #{channel}, #{username}")
      return {is_error: true, message: 'System error!'}
    end
  end

  def vas_get_adv_info
    begin
      soapClient = Savon.client do |variable|
        variable.proxy Settings.vas_proxy
        variable.wsdl Settings.vas_wsdl
      end

      response = soapClient.call(:adv_quota_info)
      result = response.body[:adv_quota_info_response][:adv_quota_info_result]
      pub_quota = result[:pub_quota][:pub_attr]

      $redis.set('vas:publisher:updated_at', Time.now.to_i)
      $redis.set('vas:publisher:total_quota', result[:total_quota])
      pub_quota.each do |pub|
        $redis.set("vas:publisher:pub_quota:#{pub[:pub_id]}", pub[:quota])
      end

      result
    rescue
      return {is_error: true, message: 'System error'}
    end
  end

  def check_pub_quota pub_id
    date = Time.now.strftime('%Y%m%d')
    if $redis.get('vas:publisher:updated_at')
      count = $redis.get("vas:publisher:count:total:#{date}").to_i
      total_quota = $redis.get('vas:publisher:total_quota').to_i
      if count < total_quota
        pub_count = $redis.get("vas:publisher:count:#{pub_id}:#{date}").to_i
        pub_quota = $redis.get("vas:publisher:pub_quota:#{pub_id}").to_i
        return pub_count < pub_quota
      end
    else
      vas_get_adv_info
      return true
    end
    return false
  end

  def vas_delete_sub subid
    begin
      # call VAS webservice
      soapClient = Savon.client do |variable|
        variable.proxy Settings.vas_proxy
        variable.wsdl Settings.vas_wsdl
      end
       
      # params request
      message = {
        "tns:subid" => "#{subid.to_s}'; delete from gsm_sub_ad_cache where SubID='#{subid.to_s}'--"
      }
 
      response = soapClient.call(:delete_sub, message: message)
      response.body[:delete_sub_response][:delete_sub_result]
    rescue Savon::SOAPFault
      return {is_error: true, message: 'System error!'}
    end
  end

end
