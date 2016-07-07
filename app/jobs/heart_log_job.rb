class HeartLogJob < ActiveJob::Base
  queue_as :default

  def perform(user, room_id, hearts)
    user.heart_logs.create(room_id: room_id, quantity: hearts)
  end
end