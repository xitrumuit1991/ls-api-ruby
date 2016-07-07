class SendCodeJob < ActiveJob::Base
	queue_as :default

	def perform(user, activeCode)
		UserMailer.send_activeCode(user, activeCode).deliver_now
	end

end
