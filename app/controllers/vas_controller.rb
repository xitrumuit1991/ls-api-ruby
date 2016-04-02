class VasController < ApplicationController
  before_filter :dump_parameters

  soap_service namespace: 'urn:livestar'

  # Mua gói VIP từ VAS
  # Args:
  # - id: mã thuê bao
  # - sub_id: số điện thoại
  # - pkg_code: mã gói cước (VIP, VIP7, VIP30, VIP2, VIP3, VIP4)
  # Return:
  # - error: mã lỗi (nếu 0 là không có lỗi, còn lại xin tham khảo tài liệu mã lỗi)
  # - message: thông báo trả về trong cả hai trường hợp thành công hoặc lỗi
  soap_action 'buy_vip_package',
    args: { id: :integer, sub_id: :string, pkg_code: :string },
    return: { error: :integer, message: :string}

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

  # Thay đỗi mật khẩu / quên mật khẩu
  # Args:
  # - sub_id: số điện thoại
  # Return:
  # - new_password: mật khẩu mới (nếu thao tác thành công)
  soap_action 'reset_password',
    args: { sub_id: :string },
    return: { error: :integer, message: :string, new_password: :string }

  # Đăng ký tài khoản
  # Args:
  # - sub_id: số điện thoại
  # Return:
  # - password: mật khẩu (nếu đăng ký thành công)
  soap_action 'register',
    args: { sub_id: :string},
    return: { error: :integer, message: :string, password: :string }

  # Gia hajn gói VIP
  # Args:
  # - sub_id: số điện thoại
  # - pkg_code: mã gói VIP muốn gia hạn, nếu để trống, tự động gia hạn gói đã active lần cuối cùng
  # Return:
  # - pkg_code: gói cước được gia hạn
  # - actived_date: ngày kích hoạt
  # - expry_date: ngày hết hạn
  soap_action 'charge_vip_package',
    args: { sub_id: :string, pkg_code: :string },
    return: { error: :integer, message: :string, pkg_code: :string, actived_date: :datetime, expry_date: :datetime }


  def buy_vip_package
    # TODO
    render soap: { error: 0, message: 'giao dich thanh cong'}
  end

  def charge_vip_package
    # TODO
    render soap: { error: 0, message: 'gia han thanh cong', pkg_code: 'VIP', actived_date: '2016-04-02 20:44:00', expry_date: '2016-04-03 20:44:00' }
  end

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

  def reset_password
    if params[:sub_id].present?
      sub_id = params[:sub_id]
      user = User.find_by_phone(sub_id)
      if user.present?
        user.password = SecureRandom.hex(5)
        if user.save
          render soap: { error: 0, message: 'Thay doi mat khau thanh cong', new_password: user.password} and return
        else
          render soap: { error: 3, message: 'can\'t reset password, contact technical supporter please', new_password: '' } and return
        end
      else
        render soap: { error: 2, message: "So dien thoai #{sub_id} khong ton tai", new_password: ''} and return
      end
    end
    render soap: { error: 1, message: 'missing arguments', new_password: '' }
  end

  def register
    if params[:sub_id].present?
      sub_id = params[:sub_id]
      if User.exists?(phone: sub_id)
        render soap: { error: 2, message: "So dien thoai #{sub_id} da duoc dang ky", password: ''}
      else
        activeCode = SecureRandom.hex(3).upcase
        user = User.new
        user.email        = "#{sub_id}@mobifone.com.vn"
        user.password     = SecureRandom.hex(5)
        user.active_code  = activeCode
        user.username     = sub_id
        user.phone        = sub_id
        if user.valid?
          user.name           = sub_id
          user.birthday       = '2000-01-01'
          user.user_level_id  = UserLevel.first().id
          user.money          = 8
          user.user_exp       = 0
          user.actived        = 1
          user.no_heart       = 0
          if user.save
            # TODO we need create MobiFoneUser also
            create_mbf_user user
            render soap: { error: 0, message: 'dang ky tai khoan thanh cong', password: user.password}
          else
            render soap: { error: 3, message: 'can\'t create user, contact technical supporter please', password: '' }
          end
        else
          render json: { error: 4, message: 'invalid user payload', password: '' }
        end
      end
    else
      render soap: { error: 1, message: 'missing arguments', password: '' }
    end
  end

  private
    def create_mbf_user(user)
      # TODO create mbf_user from User
    end
    def dump_parameters
      Rails.logger.debug params.inspect
    end
end