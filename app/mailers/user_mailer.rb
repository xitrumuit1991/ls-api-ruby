class UserMailer < ApplicationMailer
  default from: "from@example.com"
 
  def reset_password(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: 'Instruction for your new password')
  end

  def send_activeCode(user, activeCode)
    @user = user
    @activeCode = activeCode
    mail(to: @user.email, subject: 'Active your account to complete registration')
  end

  def confirm_forgot_password(user,forgot_code)
    @user= user
    @forgot_code = forgot_code
    mail(to: @user.email, subject: 'Confirm to reset password')
  end

end
