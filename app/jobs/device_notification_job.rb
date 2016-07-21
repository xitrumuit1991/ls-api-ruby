class DeviceNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(title, room_id, list_tokens)
    uri = URI.parse("http://localhost:3001/ios")
    http = Net::HTTP.new(uri.host,uri.port)
	request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = {'title' => title, 'room_id' => room_id, 'tokens' => list_tokens}.to_json
	request["Content-Type"] = "application/json"
	http.request(request)
  end
end