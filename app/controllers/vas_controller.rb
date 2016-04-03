class VasController < ApplicationController
  before_filter :filter_ip

  soap_service namespace: 'urn:livestar'

  # Cộng tiền cho thuê bao
  # Args:
  # - sub_id: số điện thoại
  # - money: số tiền cần cộng
  # - info: mô tã cho thao tác (nếu có)
  # Return:
  # - added_money: số tiền được cộng (nếu thao tác thành công)
  # - current_money: số tiền hiện tại sau khi cộnng (nếu thao tác thành công)
  soap_action 'add_money',
    args: { sub_id: :string, money: :integer, info: :string },
    return: { error: :integer, message: :string, added_money: :integer, current_money: :integer }

  def add_money
    if params[:sub_id].present? && params[:money].present?
      sub_id = params[:sub_id]
      money = params[:money]
      user = User.find_by_phone(sub_id)
      if user.present?
        new_money = user.money + money;
        if user.update(money: new_money)
          # TODO create add money log here
          render soap: { error: 0, message: 'Cong tien thanh cong', added_money: money, current_money: new_money } and return
        else
          render soap: { error: 3, message: 'can\'t add money, contact technical supporter please' } and return
        end
      else
        render soap: { error: 2, message: "So dien thoai #{sub_id} khong ton tai" } and return
      end
    end
    render soap: { error: 1, message: 'missing arguments' }
  end


  # Thay đỗi mật khẩu / quên mật khẩu
  # Args:
  # - sub_id: số điện thoại
  # Return:
  # - new_password: mật khẩu mới (nếu thao tác thành công)
  soap_action 'reset_password',
    args: { sub_id: :string },
    return: { error: :integer, message: :string, new_password: :string }

  def reset_password
    if params[:sub_id].present?
      sub_id = params[:sub_id]
      user = User.find_by_phone(sub_id)
      if user.present?
        user.password = SecureRandom.hex(5)
        if user.save
          render soap: { error: 0, message: 'Thay doi mat khau thanh cong', new_password: user.password} and return
        else
          render soap: { error: 3, message: 'can\'t reset password, contact technical supporter please' } and return
        end
      else
        render soap: { error: 2, message: "So dien thoai #{sub_id} khong ton tai" } and return
      end
    end
    render soap: { error: 1, message: 'missing arguments' }
  end


  # Đăng ký tài khoản và kích hoạt VIP
  # - Nếu chưa có user trên LS thì tạo tài khoản và kích hoạt gói VIP
  # - Nếu đã có tài khoản những chưa có (hoặc đã hết hạn) gói VIP thì kích hoạt gói VIP
  # - Nếu đã có tài khoản đã có nói VIP thấp hơn thì nâng cấp gói VIP
  # Args:
  # - sub_id: số điện thoại
  # Return:
  # - active_date: ngày kích hoạt gói VIP
  # - expiry_date: ngày hết hạn gói VIP
  soap_action 'subscribe',
    args: { sub_id: :string, pkg_code: :string, password: :string},
    return: { error: :integer, message: :string, active_date: :string, expiry_date: :string }

  def subscribe
    if params[:sub_id].present? && params[:password].present? && params[:pkg_code].present?
      sub_id = params[:sub_id]
      password = params[:password]
      pkg_code = params[:pkg_code]
      time_now = Time.now

      if create_user sub_id, password
        vip_package = VipPackage.find_by_code(pkg_code)
        if vip_package.present?
          user_has_vip_package = @user.user_has_vip_packages.where(actived: true).where('? BETWEEN active_date AND expiry_date', Time.now)
          if user_has_vip_package.present?
            user_vip_package = user_has_vip_package.take.vip_package
            if user_vip_package.vip.weight < vip_package.vip.weight
              subscribed = subscribe_vip @user, vip_package, time_now
              render soap: { error: 0, message: "Da dang ky thanh cong", active_date:  subscribed.active_date, expiry_date: subscribed.expiry_date }
            elsif user_vip_package.vip.weight == vip_package.vip.weight
              active_date = user_has_vip_package.take.expiry_date + vip_package.no_day.to_i
              subscribed = subscribe_vip @user, vip_package, active_date
              render soap: { error: 0, message: "Da dang ky thanh cong", active_date:  subscribed.active_date, expiry_date: subscribed.expiry_date }
            else
              render soap: { error: 3, message: "Tai khoan da dang ky goi VIP cao hon, vui long kiem tra lai" }
            end
          else
            subscribed = subscribe_vip @user, vip_package, time_now
            render soap: { error: 0, message: "Da dang ky thanh cong", active_date:  subscribed.active_date, expiry_date: subscribed.expiry_date}
          end
        else
          render soap: { error: 2, message: "Goi cuoc #{pkg_code} khong ton tai, vui long kiem tra lai" }
        end
      else
        render soap: { error: 1, message: 'Khong the tao tai khoan, vui long lien he ho tro ky thuat livestar' }
      end
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so' }
    end
  end


  # Gia hạn gói VIP cho thuê bao
  soap_action 'charge',
    args: { sub_id: :string },
    return: { error: :integer, message: :string, pkg_code: :string, active_date: :string, expiry_date: :string}

  def charge
    if params[:sub_id].present?
      sub_id = params[:sub_id]
      mbf_user = MobifoneUser.find_by_sub_id(sub_id)
      if mbf_user.present?
        pkg_code = mbf_user.pkg_code
        vip_package = VipPackage.find_by_code(pkg_code)
        subscribed = subscribe_vip mbf_user.user, vip_package, Time.now
        render soap: { error: 0, message: "Gia han goi VIP thanh cong", pkg_code: pkg_code, active_date: subscribed.active_date, expiry_date: subscribed.expiry_date }
      else
        render soap: { error: 2, message: "Thue bao #{sub_id} khong ton tai tren he thong" }
      end
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so' }
    end
  end


  # Gia hạn gói cước cho nhiều thuê bao
  # Return:
  # - successes: list các ID cập nhật hoặc thêm mới thành công
  # - errors: list các ID bị lỗi khi cập nhật
  soap_action 'mcharge',
    args: [:string],
    return: { error: :integer, message: :string, errors: [:integer], successes: [:integer]}

  def mcharge
    if params[:value].present?
      successes = []
      errors = []
      params[:value].each do |sub_id|
        mbf_user = MobifoneUser.find_by_sub_id(sub_id)
        if mbf_user.present?
          pkg_code = mbf_user.pkg_code
          vip_package = VipPackage.find_by_code(pkg_code)
          subscribed = subscribe_vip mbf_user.user, vip_package, Time.now
          successes << sub_id
        else
          errors << sub_id
        end
      end
      render soap: { error: 0, message: '', successes: successes, errors: errors }
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so' }
    end
  end

  private
    def subscribe_vip user, vip_package, actived_date
      expiry_date  = actived_date + vip_package.no_day.to_i.day
      user.user_has_vip_packages.update_all(actived: false)
      user.mobifone_user.update(pkg_code: vip_package.code, pkg_actived: actived_date)
      # TODO: Ghi mobifone_user_charge_log ở đây
      return user.user_has_vip_packages.create(vip_package_id: vip_package.id, actived: true, active_date: actived_date, expiry_date: expiry_date)
    end

    def create_user phone, password
      if User.exists?(phone: phone)
        @user = User.find_by_phone(phone)
        @user.create_mobifone_user(id: @user.id, sub_id: phone) if @user.mobifone_user.nil?
        return true
      else
        activeCode = SecureRandom.hex(3).upcase
        @user = User.new
        @user.email        = "#{phone}@mobifone.com.vn"
        @user.password     = password
        @user.active_code  = activeCode
        @user.username     = phone
        @user.phone        = phone
        if @user.valid?
          @user.name           = phone
          @user.birthday       = '2000-01-01'
          @user.user_level_id  = UserLevel.first().id
          @user.money          = 8
          @user.user_exp       = 0
          @user.actived        = 1
          @user.no_heart       = 0
          return true if @user.save and @user.create_mobifone_user(id: @user.id, sub_id: phone)
        end
        return false
      end
    end

    def filter_ip
      puts request.remote_ip
    end
end