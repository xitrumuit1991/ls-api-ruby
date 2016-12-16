class VirtualUsersJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    VirtualUser.all.each do |user|
			data = user.email.split("@")
			email = "livestar_#{data[0]}@#{data[1]}"
			user.update(email: email)
		end
  end
end
