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
    @user = user
    @forgot_code = forgot_code
    if @user and @forgot_code
      mail(to: @user.email, subject: 'Xác nhận quên mật khẩu')
    end
  end

  def active_account_register_web(user)
    @user = user
    active_code = Digest::MD5.hexdigest('active') #active_code=c76a5e84e4bdee527e274ea30c680d79 = md5('active')
    check_signal = Digest::MD5.hexdigest(@user.email)
    @url = 'http://livestar.vn/active_account?email='+@user.email.to_s+'&active_code='+active_code.to_s+'&check_signal='+check_signal.to_s
    if @user
      mail(to: @user.email, subject: 'Kích hoạt tài khoản')
    end
  end

end
