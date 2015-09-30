class NotificationChangeMoneyJob < ActiveJob::Base
  queue_as :default

  def perform(email, old_value, new_value)
    redis = Redis.new
    socket_id = redis.get("notification:#{email}")
    if socket_id
		emitter = SocketIO::Emitter.new
		emitter.of("/notification").in(socket_id).emit("change money", { old_value: old_value, new_value: new_value })
    end
  end
end
