class WapController < ApplicationController
  include Api::V1::Authorize
  include Api::V1::Vas
  include Api::V1::Wap

  def mbf_publisher_directly
    redirect_to 'http://m.livestar.vn' and return if !params[:publisher].present? or !check_pub_quota(params[:publisher])
    # get msisdn
    msisdn = check_mbf_auth ? @msisdn : nil
    # call api vas update
    vas_update_partner_report msisdn, params[:publisher]
    # detect user mbf 3g
    if check_mbf_auth
      # check user mbf existed
      if !@user.present?
        # call api vas register
        register_result = vas_register msisdn, "VIP", "WAP", params[:publisher], msisdn, SecureRandom.hex(3)
        if !register_result[:is_error]
          # create user mbf
          mbf_create_user msisdn
          # redirect to page cancel service of mbf
          rdlink = mbf_htt
          redirect_to rdlink and return
        end
      end
    end
    redirect_to 'http://m.livestar.vn' and return
  end

  def mbf_htt_back
    redirect_to 'http://m.livestar.vn' and return if !params[:link].present?

    # decypt data
    data = wap_mbf_decrypt(params[:link].gsub(' ', '+'), Settings.wap_mbf_htt_key)
    data = data.split("&")
    # check status
    if data[2].to_i == 1
      # get phone
      sub_id = data[1]
      # check user mbf
      mbf_user = MobifoneUser.find_by_sub_id(sub_id)
      if mbf_user.present?
        # call api vas cancel service
        result = vas_cancel_service sub_id, "VIP", "WAP", mbf_user.user.username
        if !result[:is_error]
          mbf_user.user.user_has_vip_packages.update_all(actived: false)
        else
          render json: { error: "Vas error !" }, status: 400
        end
      else
        render json: { error: "Thue bao #{sub_id} khong ton tai tren he thong !" }, status: 400
      end
    end
    redirect_to 'http://m.livestar.vn'
  end

  private
  	def mbf_create_user msisdn
      activeCode = SecureRandom.hex(3).upcase
      user = User.new
      user.phone          = msisdn
      user.email          = "#{msisdn}@livestar.vn"
      user.password       = msisdn
      user.active_code    = activeCode
      user.name           = msisdn.to_s[0,msisdn.to_s.length-3]+"xxx"
      user.username       = msisdn
      user.birthday       = '2000-01-01'
      user.user_level_id  = UserLevel.first().id
      user.money          = 8
      user.user_exp       = 0
      user.no_heart       = 0
      user.actived        = true
      user.active_date    = Time.now
      user.save
      # create mobifone user
      user.create_mobifone_user(sub_id: msisdn, pkg_code: "VIP", register_channel: "WAP", active_date: Time.now, expiry_date: Time.now + 1.days, status: 1)
      # get vip1
      vip1 = VipPackage.find_by(code: 'VIP', no_day: 1)
      # subscribe vip1
      user_has_vip_package = user.user_has_vip_packages.create(vip_package_id: vip1.id, actived: 1, active_date: Time.now, expiry_date: Time.now + 1.days)
      # create mobifone user vip logs
      user.mobifone_user.mobifone_user_vip_logs.create(user_has_vip_package_id: user_has_vip_package.id, pkg_code: "VIP")
      # add bonus coins for user
      money = user.money + vip1.discount
      user.update(money: money)
    end

  	def mbf_htt
      sp_id       = 140
      trans_id    = Time.now.to_i
      pkg         = "VIP"
      back_url    = "#{Settings.base_url}/huy"
      information = "Mien phi 1 ngay"

      # encrypt data
      data = "#{trans_id}&#{pkg}&#{back_url}&#{information}"
      link = wap_mbf_encrypt(data, Settings.wap_mbf_htt_key)

      return "#{Settings.wap_mbf_htt_url}?sp_id=#{sp_id}&link=#{link}"
    end

end