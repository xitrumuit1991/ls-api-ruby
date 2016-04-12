class Api::V1::VipController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include Api::V1::Vas

  before_action :authenticate, except: [:listVip, :mbf_get_vip_packages]

  def buyVip
    vipPackage = VipPackage::find(params[:vip_package_id])
    if @user.money >= vipPackage.price
      if @user.user_has_vip_packages.where(:actived => true).present?
        user_vip = @user.user_has_vip_packages.where(:actived => true).take.vip_package
        if user_vip.vip.weight < vipPackage.vip.weight
          @user.user_has_vip_packages.update_all(actived: false)
          UserHasVipPackage.create(user_id: @user.id, vip_package_id: params[:vip_package_id], actived: true, active_date: Time.now, expiry_date: Time.now + vipPackage.no_day.to_i.day)
          @user.decreaseMoney(vipPackage.price)
          return head 200
        elsif user_vip.vip.weight == vipPackage.vip.weight
          dateActive = @user.user_has_vip_packages.where(:actived => true).take.expiry_date
          @user.user_has_vip_packages.update_all(actived: false)
          UserHasVipPackage.create(user_id: @user.id, vip_package_id: params[:vip_package_id], actived: true, active_date: Time.now, expiry_date: dateActive + vipPackage.no_day.to_i.day)
          @user.decreaseMoney(vipPackage.price)
          return head 200
        else
          render json: {error: "Vui lòng mua VIP cao hơn hoặc bằng với VIP hiện tại!"}, status: 403
        end
      else
        UserHasVipPackage.create(user_id: @user.id, vip_package_id: params[:vip_package_id], actived: true, active_date: Time.now, expiry_date: Time.now + vipPackage.no_day.to_i.day)
        @user.decreaseMoney(vipPackage.price)
        return head 200
      end
    else
      render json: {error: "Bạn không có đủ tiền"}, status: 403
    end
  end

  def mbf_get_vip_packages
    @packages = VipPackage.where(code: ["VIP", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4"])
  end

  def mbf_subscribe_vip_package
    # render json: { error: "Request not from Mobifone 3G" }, status: 403 and return if !check_mbf_auth
    render json: { error: "Gói VIP này không tồn tại !" }, status: 400 and return if !["VIP", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4"].include? params[:pkg_code]

    if @user.mobifone_user.present?
      vipPackage = VipPackage.find_by(code: params[:pkg_code])
      if vipPackage.present?
        if @user.user_has_vip_packages.find_by(actived: true).present?
          user_vip = @user.user_has_vip_packages.find_by(actived: true).vip_package
          if user_vip.vip.weight < vipPackage.vip.weight
            expiry_date = Time.now + vipPackage.no_day.to_i.day
            create_vip_package vipPackage, expiry_date
            return head 200
          elsif user_vip.vip.weight == vipPackage.vip.weight
            expiry_date = user_vip.expiry_date + vipPackage.no_day.to_i.day
            create_vip_package vipPackage, expiry_date
            return head 200
          else
            render json: {error: "Vui lòng mua VIP cao hơn hoặc bằng với VIP hiện tại!"}, status: 403
          end
        else
          expiry_date = Time.now + vipPackage.no_day.to_i.day
          create_vip_package vipPackage, expiry_date
          return head 200
        end
      else
        render json: {error: "Gói VIP này không tồn tại !"}, status: 400
      end
    else
      render json: {error: "Bạn chưa có tài khoản Mobifone !"}, status: 401
    end
  end

  def listVip
    @vips =  Vip.where('code != ? and code != ? and code != ? and code != ? and code != ? and code != ?', "VIP1", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4")
    @day = params[:day]
  end

  private
    def create_vip_package vipPackage, expiry_date
      charge_result = vas_charge @user.phone, "APP", vipPackage.price, vipPackage.id, "Test", "APP", "BUY_VIP"
      if !charge_result[:is_error]
        # set actived false if user has vip package
        @user.user_has_vip_packages.find_by(actived: true).update(actived: false) if @user.user_has_vip_packages.find_by(actived: true).present?
        # subscribe vip package
        user_has_vip_package = @user.user_has_vip_packages.create(vip_package_id: vipPackage.id, actived: true, active_date: Time.now, expiry_date: expiry_date)
        # create mobifone user vip logs
        @user.mobifone_user.mobifone_user_vip_logs.create(user_has_vip_package_id: user_has_vip_package.id, pkg_code: vipPackage.code)
      else
        render json: { error: "Có lổi xảy ra, bạn đăng ký lại !" }, status: 400 and return
      end
    end
end