class WapController < ApplicationController
  include Api::V1::Authorize
  include Api::V1::Vas
  include Api::V1::Wap

  def mbf_publisher_directly
    waplogger = Logger.new("#{Rails.root}/log/wap_mbf_publisher_directly.log")
    waplogger.info("#{params[:publisher]}")
    redirect_to Settings.m_livestar_path and return if !params[:publisher].present?
    # get msisdn
    msisdn = check_mbf_auth ? @msisdn : nil
    waplogger.info("msisdn: #{msisdn}")
    # call api vas update
    vas_update_partner_report msisdn, params[:publisher]
    # detect user mbf 3g
    if check_mbf_auth
      # check user mbf existed
      if !@user.present?
        # call api vas register
        register_result = vas_register msisdn, "VIP", "WAP", params[:publisher], msisdn, SecureRandom.hex(3)
        waplogger.info(register_result)
        if !register_result[:is_error]
          # redirect to page cancel service of mbf
          rdlink = mbf_htt
          redirect_to rdlink and return
        else
          if register_result[:message] == 'OUT_OF_SYSTEM_QUOTA' or register_result[:message] == 'OUT_OF_PUB_QUOTA'
            rdlink = wap_mbf_register_request
            waplogger.info("redirect to  #{rdlink}")
            redirect_to rdlink and return
          end
        end
      else
        waplogger.info("user.vip #{@user.vip}")
        if @user.vip == 0
          rdlink = wap_mbf_register_request
          waplogger.info("redirect to #{rdlink}")
          redirect_to rdlink and return
        end
      end
    end
    redirect_to Settings.m_livestar_path and return
  end


  def mbf_publisher
    waplogger = Logger.new("#{Rails.root}/log/wap_mbf_publisher_directly.log")
    waplogger.info("publisher: #{params[:publisher]}")
    waplogger.info("pkg: #{params[:pkg]}")

    redirect_to Settings.m_livestar_path and return if !params[:publisher].present? or !params[:pkg].present?

    allowed_pkg = ['VIP','VIP7','VIP30','VIP2N','VIP2','VIP3N','VIP3N','VIP4']

    redirect_to Settings.m_livestar_path and return if !allowed_pkg.include?(params[:pkg])

    package = VipPackage.find_by_code(params[:pkg])

    # get msisdn
    msisdn = check_mbf_auth ? @msisdn : nil
    waplogger.info("msisdn: #{msisdn}")
    # call api vas update
    vas_update_partner_report msisdn, params[:publisher], package.code
    # detect user mbf 3g
    if check_mbf_auth
      # check user mbf existed
      if !@user.present?
        # call api vas register
        register_result = vas_register msisdn, package.code, "WAP", params[:publisher], msisdn, SecureRandom.hex(3)
        waplogger.info(register_result)
        if !register_result[:is_error]
          # redirect to page cancel service of mbf
          rdlink = mbf_htt(package.code)
          waplogger.info("redirect to  #{rdlink}")
          redirect_to rdlink and return
        else
          if register_result[:message] == 'OUT_OF_SYSTEM_QUOTA' or register_result[:message] == 'OUT_OF_PUB_QUOTA'
            rdlink = wap_mbf_register_request(package.code, package.price)
            waplogger.info("redirect to  #{rdlink}")
            redirect_to rdlink and return
          end
        end
      else
        if !@user.vip
          rdlink = wap_mbf_register_request(package.code, package.price)
          waplogger.info("redirect to  #{rdlink}")
          redirect_to rdlink and return
        end
      end
    end
    redirect_to Settings.m_livestar_path and return
  end

  def mbf_htt_back
    waplogger = Logger.new("#{Rails.root}/log/wap_mbf_publisher_directly.log")
    redirect_to Settings.m_livestar_path and return if !params[:link].present?

    # decypt data
    data = wap_mbf_decrypt(params[:link].gsub(' ', '+'), Settings.wap_mbf_htt_key)
    waplogger.info("data: #{data}")
    data = data.split("&")
    # check status
    if data[2].to_i == 1
      # get phone
      sub_id = data[1]
      # check user mbf
      mbf_user = MobifoneUser.find_by_sub_id(sub_id)
      waplogger.info("mbf_user.present?: #{mbf_user.present?}")
      if mbf_user.present?
        # call api vas cancel service
        result = vas_cancel_service sub_id, mbf_user.pkg_code, "WAP", mbf_user.user.username
        waplogger.info(result)
        if !result[:is_error]
          mbf_user.user.user_has_vip_packages.update_all(actived: false)
        else
          render json: { error: "Vas error !" }, status: 400
        end
      else
        render json: { error: "Thue bao #{sub_id} khong ton tai tren he thong !" }, status: 400
      end
    end
    redirect_to Settings.m_livestar_path
  end

  private
  	def mbf_htt(pkg = "VIP")
      waplogger = Logger.new("#{Rails.root}/log/wap_mbf_publisher_directly.log")
      sp_id       = 140
      trans_id    = Time.now.to_i
      pkg         = pkg
      back_url    = "#{Settings.base_url}/huy"
      information = pkg_info(pkg)

      # encrypt data
      data = "#{trans_id}&#{pkg}&#{back_url}&#{information}"
      link = wap_mbf_encrypt(data, Settings.wap_mbf_htt_key)
      waplogger.info("return: #{Settings.wap_mbf_htt_url}?sp_id=#{sp_id}&link=#{link}")

      return "#{Settings.wap_mbf_htt_url}?sp_id=#{sp_id}&link=#{link}"
    end
    
    def wap_mbf_register_request(pkg = "VIP", price = 2000)
      sp_id       = 140
      trans_id    = Time.now.to_i
      back_url    = "#{Settings.base_url}api/v1/auth/twotouches"
      information = pkg_info(pkg)
    
      # insert wap mbf logs
      WapMbfLog.create(sp_id: sp_id, trans_id: trans_id, pkg: pkg, price: price, information: information)
      # encrypt data
      data = "#{trans_id}&#{pkg}&#{price}&#{back_url}&#{information}"
    
      link = wap_mbf_encrypt data, Settings.wap_mbf_key
      return "#{Settings.wap_register_url}?sp_id=#{sp_id}&link=#{link}"
    end

    def pkg_info(pkg)
      pkg_info = {
        "VIP": "##81;##117;##253;##32;##107;##104;##225;##99;##104;##32;##273;##432;##7907;##99;##32;##109;##105;##7877;##110;##32;##112;##104;##237;##32;##49;##32;##110;##103;##224;##121;##44;##32;##115;##97;##117;##32;##75;##77;##44;##32;##99;##432;##7899;##99;##32;##50;##46;##48;##48;##48;##273;##47;##110;##103;##224;##121;",
        "VIP7": "##81;##117;##253;##32;##107;##104;##225;##99;##104;##32;##273;##432;##7907;##99;##32;##109;##105;##7877;##110;##32;##112;##104;##237;##32;##49;##32;##110;##103;##224;##121;##44;##32;##115;##97;##117;##32;##75;##77;##44;##32;##99;##432;##7899;##99;##32;##49;##48;##46;##48;##48;##48;##273;##47;##116;##117;##7847;##110;",
        "VIP30": "##81;##117;##253;##32;##107;##104;##225;##99;##104;##32;##273;##432;##7907;##99;##32;##109;##105;##7877;##110;##32;##112;##104;##237;##32;##49;##32;##110;##103;##224;##121;##44;##32;##115;##97;##117;##32;##75;##77;##44;##32;##99;##432;##7899;##99;##32;##51;##48;##46;##48;##48;##48;##273;##47;##116;##104;##225;##110;##103;",
        "VIP2N": "##81;##117;##253;##32;##107;##104;##225;##99;##104;##32;##273;##432;##7907;##99;##32;##109;##105;##7877;##110;##32;##112;##104;##237;##32;##49;##32;##110;##103;##224;##121;##44;##32;##115;##97;##117;##32;##75;##77;##44;##32;##99;##432;##7899;##99;##32;##51;##46;##48;##48;##48;##273;##47;##110;##103;##224;##121;",
        "VIP2": "##81;##117;##253;##32;##107;##104;##225;##99;##104;##32;##273;##432;##7907;##99;##32;##109;##105;##7877;##110;##32;##112;##104;##237;##32;##49;##32;##110;##103;##224;##121;##44;##32;##115;##97;##117;##32;##75;##77;##44;##32;##99;##432;##7899;##99;##32;##50;##48;##46;##48;##48;##48;##273;##47;##116;##117;##7847;##110;",
        "VIP3N": "##81;##117;##253;##32;##107;##104;##225;##99;##104;##32;##273;##432;##7907;##99;##32;##109;##105;##7877;##110;##32;##112;##104;##237;##32;##49;##32;##110;##103;##224;##121;##44;##32;##115;##97;##117;##32;##75;##77;##44;##32;##99;##432;##7899;##99;##32;##53;##46;##48;##48;##48;##273;##47;##110;##103;##224;##121;",
        "VIP3": "##81;##117;##253;##32;##107;##104;##225;##99;##104;##32;##273;##432;##7907;##99;##32;##109;##105;##7877;##110;##32;##112;##104;##237;##32;##49;##32;##110;##103;##224;##121;##44;##32;##115;##97;##117;##32;##75;##77;##44;##32;##99;##432;##7899;##99;##32;##51;##48;##46;##48;##48;##48;##273;##47;##116;##117;##7847;##110;",
        "VIP4": "##81;##117;##253;##32;##107;##104;##225;##99;##104;##32;##273;##432;##7907;##99;##32;##109;##105;##7877;##110;##32;##112;##104;##237;##32;##49;##32;##110;##103;##224;##121;##44;##32;##115;##97;##117;##32;##75;##77;##44;##32;##99;##432;##7899;##99;##32;##53;##48;##46;##48;##48;##48;##273;##47;##116;##117;##7847;##110;",
      }

      return pkg_info[pkg.to_sym]
    end

end