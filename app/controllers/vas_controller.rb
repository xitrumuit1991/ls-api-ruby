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
  # - id: mã thuê bao
  # - sub_id: số điện thoại
  # - money: số tiền cần cộng
  # - info: mô tã cho thao tác (nếu có)
  # Return:
  # - added_money: số tiền được cộng (nếu thao tác thành công)
  # - current_money: số tiền hiện tại sau khi cộnng (nếu thao tác thành công)
  soap_action 'add_money',
    args: { id: :integer, sub_id: :string, money: :integer, info: :string },
    return: { error: :integer, message: :string, added_money: :integer, current_money: :integer }

  # Thay đỗi mật khẩu / quên mật khẩu
  # Args:
  # - id: mã thuê bao
  # - sub_id: số điện thoại
  # Return:
  # - new_password: mật khẩu mới (nếu thao tác thành công)
  soap_action 'reset_password',
    args: { id: :integer, sub_id: :string },
    return: { error: :integer, message: :string, new_password: :string }

  # Đăng ký tài khoản
  # Args:
  # - id: mã thuê bao
  # - sub_id: số điện thoại
  # Return:
  # - password: mật khẩu (nếu đăng ký thành công)
  soap_action 'register',
    args: { id: :integer, sub_id: :string},
    return: { error: :integer, message: :string, password: :string }

  def buy_vip_package
    # TODO
    render soap: { error: 0, message: 'giao dich thanh cong'}
  end

  def add_money
    # TODO
    render soap: { error: 0, message: 'thao tac thanh cong', added_money: 0, current_money: 0}
  end

  def reset_password
    # TODO
    render soap: { error: 0, message: 'mat khau da thay doi', new_password: 'newpassword' }
  end

  def register
    # TODO
    render soap: { error: 0, message: 'dang ky tai khoan thanh cong', password: 'password'}
  end

  private
    def dump_parameters
      Rails.logger.debug params.inspect
    end
end