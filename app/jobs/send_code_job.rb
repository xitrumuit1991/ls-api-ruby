class SendCodeJob < ActiveJob::Base
  queue_as :sendActiveCode

  def perform(user, activeCode)
    UserMailer.send_activeCode(user, activeCode).deliver_later
	end

end
