class Api::V1::VipController < Api::V1::ApplicationController
  include Api::V1::Authorize
  before_action :authenticate, except: [:listVip, :testSoap]

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
end