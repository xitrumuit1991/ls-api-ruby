class VasController < ActionController::Base
	protect_from_forgery with: :null_session
	skip_before_action :verify_authenticity_token
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
      info = params[:info]
      user = User.find_by_phone(sub_id)
      if user.present?
        new_money = user.money + money;
        if user.update(money: new_money)
          MobifoneUserMoneyLog.create(mobifone_user_id: user.mobifone_user.id, money: money, info: info)
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
        user.password = SecureRandom.hex(3)
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
            if user_vip_package.vip.weight <= vip_package.vip.weight
              subscribed = subscribe_vip @user, vip_package, time_now, time_now + 1.day
              render soap: { error: 0, message: "Da dang ky thanh cong", active_date:  subscribed.active_date, expiry_date: subscribed.expiry_date }
            else
              render soap: { error: 4, message: "Tai khoan da dang ky goi VIP cao hon, vui long kiem tra lai" }
            end
          else
            subscribed = subscribe_vip @user, vip_package, time_now, time_now + 1.day
            render soap: { error: 0, message: "Da dang ky thanh cong", active_date:  subscribed.active_date, expiry_date: subscribed.expiry_date}
          end
        else
          render soap: { error: 3, message: "Goi cuoc #{pkg_code} khong ton tai, vui long kiem tra lai" }
        end
      else
        render soap: { error: 2, message: 'Khong the tao tai khoan, vui long lien he ho tro ky thuat livestar' }
      end
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so' }
    end
  end

  # Huy toan bo goi VIP (neu co)
  soap_action 'unsubscribe',
    args: { sub_id: :string },
    return: { error: :integer, message: :string }
  def unsubscribe
    if params[:sub_id].present?
      sub_id = params[:sub_id]
      mbf_user = MobifoneUser.find_by_sub_id(sub_id)
      if mbf_user.present?
        mbf_user.user.user_has_vip_packages.update_all(actived: false)
        render soap: { error: 0, message: "Huy dich vu thanh cong" }
      else
        render soap: { error: 2, message: "Thue bao #{sub_id} khong ton tai tren he thong" }
      end
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so' }
    end
  end


  # Gia hạn gói VIP cho thuê bao
  soap_action 'charge',
    args: { sub_id: :string, pkg_code: :string },
    return: { error: :integer, message: :string, pkg_code: :string, active_date: :string, expiry_date: :string}

  def charge
    if params[:sub_id].present? && params[:pkg_code].present?
      pkg_code = params[:pkg_code]
      vip_package = VipPackage.find_by_code(pkg_code) 
      if vip_package.present?
        sub_id = params[:sub_id]
        mbf_user = MobifoneUser.find_by_sub_id(sub_id)
        if mbf_user.present?
          user = mbf_user.user
        else
          if create_user sub_id, sub_id
            user = @user
          else
            render soap: { error: 2, message: 'Khong the tao tai khoan, vui long lien he ho tro ky thuat livestar' } and return
          end
        end
        subscribed = subscribe_vip user, vip_package, Time.now
        render soap: { error: 0, message: "Gia han goi VIP thanh cong", pkg_code: pkg_code, active_date: subscribed.active_date, expiry_date: subscribed.expiry_date }
      else
        render soap: { error: 2, message: "Goi cuoc #{pkg_code} khong ton tai, vui long kiem tra lai" }
      end
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so' }
    end
  end

  # def charge
  #   if params[:sub_id].present? && params[:pkg_code].present?
  #     sub_id = params[:sub_id]
  #     mbf_user = MobifoneUser.find_by_sub_id(sub_id)
  #     if mbf_user.present?
  #       pkg_code = params[:pkg_code]
  #       vip_package = VipPackage.find_by_code(pkg_code) 
  #       if vip_package.present?
  #         subscribed = subscribe_vip mbf_user.user, vip_package, Time.now
  #         render soap: { error: 0, message: "Gia han goi VIP thanh cong", pkg_code: pkg_code, active_date: subscribed.active_date, expiry_date: subscribed.expiry_date }
  #       else
  #         render soap: { error: 2, message: "Goi cuoc #{pkg_code} khong ton tai, vui long kiem tra lai" }
  #       end
  #     else
  #       render soap: { error: 2, message: "Thue bao #{sub_id} khong ton tai tren he thong" }
  #     end
  #   else
  #     render soap: { error: 1, message: 'Vui long nhap day du tham so' }
  #   end
  # end


  # Gia hạn gói cước cho nhiều thuê bao
  # Return:
  # - successes: list các ID cập nhật hoặc thêm mới thành công
  # - errors: list các ID bị lỗi khi cập nhật
  soap_action 'mcharge',
    args: { data: :string },
    return: { error: :integer, message: :string, errors: [:string], successes: [:string]}

  def mcharge
  	return render soap: { error: 1, message: 'Vui long nhap day du tham so' }, status: 200 if params[:data].blank?
    if params[:data].present?
      successes = []
      errors = []
      data = params[:data].split(",")
      data.each do |item|
        object    = item.split("_")
        sub_id    = object[0]
        pkg_code  = object[1]
        vip_package = VipPackage.find_by_code(pkg_code)
        if vip_package.present?
          mbf_user = MobifoneUser.find_by_sub_id(sub_id)
          if mbf_user.present?
            subscribed = subscribe_vip mbf_user.user, vip_package, Time.now
            successes << sub_id
          else
            if create_user sub_id, sub_id
              subscribed = subscribe_vip @user, vip_package, Time.now
              successes << sub_id
            else
              errors << sub_id
            end
          end
        else
          errors << sub_id
        end
      end
      render soap: { error: 0, message: '', successes: successes, errors: errors }
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so' }
    end
  end

  # def mcharge
  #   if params[:data].present?
  #     successes = []
  #     errors = []
  #     data = params[:data].split(",")
  #     data.each do |item|
  #       object    = item.split("_")
  #       sub_id    = object[0]
  #       pkg_code  = object[1]
  #       mbf_user = MobifoneUser.find_by_sub_id(sub_id)
  #       if mbf_user.present?
  #         vip_package = VipPackage.find_by_code(pkg_code)
  #         subscribed = subscribe_vip mbf_user.user, vip_package, Time.now
  #         successes << sub_id
  #       else
  #         errors << sub_id
  #       end
  #     end
  #     render soap: { error: 0, message: '', successes: successes, errors: errors }
  #   else
  #     render soap: { error: 1, message: 'Vui long nhap day du tham so' }
  #   end
  # end

  # Kiểm tra username tồn tại
  # Args:
  # - username: tên đăng nhập
  # Retuen:
  # - is_member: true / false
  soap_action 'check_username',
    args: { username: :string },
    return: { error: :integer, message: :string, is_member: :boolean }
  def check_username
    if params[:username].present?
      @user = User.find_by_username(params[:username])
      render soap: { error: 0, message: '', is_member: @user.present? }
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so', is_member: false }
    end
  end

  # Tặng tiền cho user
  # Args:
  # - from: số điện thoại người tặng
  # - to: username của người nhận
  # - money: Số tiền tặng
  # - note (optional): ghi chú
  soap_action 'send_money',
    args: { from: :string, to: :string, money: :integer, note: :string },
    return: { error: :integer, message: :string }
  def send_money
    if params[:from].present? and  params[:to].present? and params[:money].present?
      money = params[:money].to_i
      if money < 1
        render soap: { error: 2, message: 'So tien khong hop le'} and return
      end
      @user = User.find_by_username(params[:to])
      if @user.present?
        begin
          @user.increaseMoney(money)
          note = params[:note].present? ? params[:note] : nil
          SendMoneyLog.create(from: params[:from], user_id: @user.id, money: money, note: note)
          render soap: { error: 0, message: 'Tang tien thanh cong' }
        rescue Exception => e
          render soap: { error: 4, message: "Khong the tang tien cho user, #{e.message}"}
        end
      else
        render soap: { error: 3, message: "Tai khoan #{params[:to]} khong ton tai"}
      end
    else
      render soap: { error: 1, message: 'Vui long nhap day du tham so' }
    end
  end

  private
    def subscribe_vip user, vip_package, actived_date, expiry = false
      unless check_package_free user
        # add bonus coins for user
        money = user.money + vip_package.discount
        user.update(money: money)
      end
      expiry_date  = expiry ? expiry : actived_date + vip_package.no_day.to_i.day
      user.user_has_vip_packages.update_all(actived: false) if user.user_has_vip_packages.present?
      user.mobifone_user.update(pkg_code: vip_package.code, active_date: actived_date, expiry_date: expiry_date)
      user_has_vip_package = user.user_has_vip_packages.create(vip_package_id: vip_package.id, actived: true, active_date: actived_date, expiry_date: expiry_date)
      MobifoneUserVipLog.create(mobifone_user_id: user.mobifone_user.id, user_has_vip_package_id: user_has_vip_package.id, pkg_code: user.mobifone_user.pkg_code)
      return user_has_vip_package
    end

    def create_user phone, password
      if User.exists?(phone: phone)
        @user = User.find_by_phone(phone)
        @user.create_mobifone_user(sub_id: phone) if @user.mobifone_user.nil?
        return true
      else
        activeCode = SecureRandom.hex(3).upcase
        @user = User.new
        @user.email        = "#{phone}@livestar.vn"
        @user.password     = password
        @user.active_code  = activeCode
        @user.username     = phone
        @user.phone        = phone
        @user.name         = phone.to_s[0,phone.to_s.length-3]+"xxx"
        if @user.valid?
          @user.birthday       = '2000-01-01'
          @user.user_level_id  = UserLevel.first().id
          @user.money          = 8
          @user.user_exp       = 0
          @user.actived        = 1
          @user.no_heart       = 0
          return true if @user.save and @user.create_mobifone_user(sub_id: phone)
        end
        return false
      end
    end

    def check_package_free user
      if user.user_has_vip_packages.present?
        if user.user_has_vip_packages.first.active_date.to_date == Time.now.to_date
          return true
        else
          return false
        end
      else
        return false
      end
    end

    def filter_ip
      # puts "request.remote_ip="
      # puts request.remote_ip
    end
end