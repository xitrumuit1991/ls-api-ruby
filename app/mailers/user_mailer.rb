class UserMailer < ApplicationMailer
  default from: "from@example.com"
 
  def reset_password(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: 'Instruction for your new password')
  end

end
