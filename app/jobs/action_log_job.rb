class ActionLogJob < ActiveJob::Base
  queue_as :default

  def perform(user, room_id, action_id, cost)
    user.action_logs.create(room_id: room_id, room_action_id: action_id, cost: cost)
  end
end