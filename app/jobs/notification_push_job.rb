class NotificationPushJob < ActiveJob::Base
  queue_as :default

  def perform(room_id, title, description, list_ios_tokens, list_android_tokens)
    if list_ios_tokens.count > 0
      uri = URI.parse(Settings.url_notification+"/ios")
      http = Net::HTTP.new(uri.host,uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = {'title' => title, 'description' => description, 'room_id' => room_id, 'type' => type, 'tokens' => list_ios_tokens}.to_json
      request["Content-Type"] = "application/json"
      http.request(request)
    end
    if list_android_tokens.count > 0
      uri = URI.parse(Settings.url_notification+"/android")
      http = Net::HTTP.new(uri.host,uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = {'title' => title, 'description' => description, 'room_id' => room_id, 'type' => type, 'tokens' => list_android_tokens}.to_json
      request["Content-Type"] = "application/json"
      http.request(request)
    end
  end
end