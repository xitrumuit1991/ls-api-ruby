class UserMailer < ApplicationMailer
  default from: "Hỗ trợ livestar <support@livestar.com>"

  def reset_password(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: 'Mật khẩu mới')
  end

  def send_activeCode(user, activeCode)
    @user = user
    @activeCode = activeCode
    mail(to: @user.email, subject: 'Kích hoạt tài khoản của bạn để hoàn thành kích hoạt')
  end

  def confirm_forgot_password(user,forgot_code)
    @user= user
    @forgot_code = forgot_code
    mail(to: @user.email, subject: 'Xác nhận quên mật khẩu')
  end

end
