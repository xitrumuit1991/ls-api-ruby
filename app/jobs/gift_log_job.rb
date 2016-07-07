class GiftLogJob < ActiveJob::Base
  queue_as :default

  def perform(user, room_id, gift_id, quantity, total)
    user.gift_logs.create(room_id: room_id, gift_id: gift_id, quantity: quantity, cost: total)
  end
end