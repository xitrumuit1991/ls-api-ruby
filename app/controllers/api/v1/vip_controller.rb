class Api::V1::VipController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include Api::V1::Vas

  before_action :authenticate, except: [:listVip, :mbf_get_vip_packages, :listVipWebMBF, :listVipAppMBF]

  def buyVip
    vipPackage = VipPackage::find(params[:vip_package_id])
    if @user.money >= vipPackage.price - vipPackage.discount
      if @user.user_has_vip_packages.where(:actived => true).present?
        user_vip = @user.user_has_vip_packages.where(:actived => true).take.vip_package
        if user_vip.vip.weight < vipPackage.vip.weight
          @user.user_has_vip_packages.update_all(actived: false)
          UserHasVipPackage.create(user_id: @user.id, vip_package_id: params[:vip_package_id], actived: true, active_date: Time.now, expiry_date: Time.now + vipPackage.no_day.to_i.day)
          @user.decreaseMoney(vipPackage.price - vipPackage.discount)
          return head 200
        elsif user_vip.vip.weight == vipPackage.vip.weight
          dateActive = @user.user_has_vip_packages.where(:actived => true).take.expiry_date
          @user.user_has_vip_packages.update_all(actived: false)
          UserHasVipPackage.create(user_id: @user.id, vip_package_id: params[:vip_package_id], actived: true, active_date: Time.now, expiry_date: dateActive + vipPackage.no_day.to_i.day)
          @user.decreaseMoney(vipPackage.price - vipPackage.discount)
          return head 200
        else
          render json: {error: "Vui lòng mua VIP cao hơn hoặc bằng với VIP hiện tại!"}, status: 400
        end
      else
        UserHasVipPackage.create(user_id: @user.id, vip_package_id: params[:vip_package_id], actived: true, active_date: Time.now, expiry_date: Time.now + vipPackage.no_day.to_i.day)
        @user.decreaseMoney(vipPackage.price - vipPackage.discount)
        return head 200
      end
    else
      render json: {error: "Bạn không có đủ tiền"}, status: 400
    end
  end

  def confirmVip
    @vip = @user.checkVip == 1 ? @user.user_has_vip_packages.find_by_actived(true).vip_package.vip : 0
  end

  def mbf_get_vip_packages
    @packages = VipPackage.where(code: ["VIP", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4"])
  end

  def mbf_subscribe_vip_package
    # render json: { error: "Request not from Mobifone 3G" }, status: 400 and return if !check_mbf_auth
    render json: { error: "Gói VIP này không tồn tại !" }, status: 400 and return if !["VIP", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4"].include? params[:pkg_code]

    if @user.mobifone_user.present?
      vipPackage = VipPackage.find_by(code: params[:pkg_code])
      if vipPackage.present?
        user_has_vip_package = @user.user_has_vip_packages.find_by(actived: true)
        if user_has_vip_package.present?
          if user_has_vip_package.vip_package.vip.weight = vipPackage.vip.weight
            if user_has_vip_package.vip_package.no_day.to_i >= vipPackage.no_day.to_i
              render json: {error: "Vui lòng mua VIP cao hơn VIP hiện tại!"}, status: 400 and return
            end
          elsif user_has_vip_package.vip_package.vip.weight > vipPackage.vip.weight
            render json: {error: "Vui lòng mua VIP cao hơn VIP hiện tại!"}, status: 400 and return
          end
        end

        result = create_vip_package vipPackage
        if result[:is_error]
          render json: { error: "#{handle_vas_error result[:message]}" }, status: 400
        else
          return head 201
        end
      else
        render json: {error: "Gói VIP này không tồn tại !"}, status: 400
      end
    else
      render json: {error: "Bạn chưa có tài khoản Mobifone !"}, status: 401
    end
  end

  def listVip
    @vips =  Vip.all
    @day = params[:day]
  end

  def listVipAppMBF
    @mode = params[:code].to_i
    # @vip = @mode == 0 ? Vip.all : VipPackage.where(code: ["VIP", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4"])
    @vip = Vip.all
  end

  def listVipWebMBF
    @vip_packages = VipPackage.where(code: ["VIP", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4"])
  end

  private
    def create_vip_package vipPackage
      charge_result = vas_register @user.phone, vipPackage.code
      if !charge_result[:is_error]
        # set actived false if user has vip package
        @user.user_has_vip_packages.find_by(actived: true).update(actived: false) if @user.user_has_vip_packages.find_by(actived: true).present?
        # update user mobifone actived
        @user.mobifone_user.update(pkg_code: vipPackage.code, active_date: Time.now, expiry_date: Time.now + vipPackage.no_day.to_i.day)
        # subscribe vip package
        user_has_vip_package = @user.user_has_vip_packages.create(vip_package_id: vipPackage.id, actived: true, active_date: Time.now, expiry_date: Time.now + vipPackage.no_day.to_i.day)
        # create mobifone user vip logs
        @user.mobifone_user.mobifone_user_vip_logs.create(user_has_vip_package_id: user_has_vip_package.id, pkg_code: vipPackage.code)
        # add bonus coins for user
        money = @user.money + vipPackage.discount
        @user.update(money: money)
      end
      return charge_result
    end

    def handle_vas_error error
      result = case error
        when "NOT_ENOUGH_MONEY_REG" then "Đăng ký lần đầu Không đủ tiền"
        when "REGISTER_BACK_FAIL" then "Đăng ký lại, không đủ tiền"
        when "ALREADY_REGISTERED" then "Đã đăng ký"
        when "IS_IN_CHARGING" then "Hệ thống đang thực hiện quá trình trừ cước với thuê bao này"
        when "NUMBER_IS_IN_BLACKLIST" then "Không được phép dùng dịch vụ do nằm trong blacklist của hệ thống"
        when "INVALID_NUMBER_FORMAT" then "Sai định dạng số điện thoại Mobi"
        when "REGISTER_ERROR" then "Không tìm thấy dữ liệu"
        else error
      end
    end
end