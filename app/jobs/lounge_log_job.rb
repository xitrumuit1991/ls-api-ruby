class LoungeLogJob < ActiveJob::Base
  queue_as :default

  def perform(user, room_id, lounge, cost)
	user.lounge_logs.create(room_id: room_id, lounge: lounge, cost: cost)
  end
end