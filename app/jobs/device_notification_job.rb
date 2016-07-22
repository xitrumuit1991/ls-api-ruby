class DeviceNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(user)
  	list_ios_tokens = []
    list_android_tokens = []
    title = 'Livestar'
    description = 'Idol '+user.broadcaster.fullname+ ' xinh đẹp đang online, vào chém gió cùng Idol nào các bạn!'
    room_id = user.broadcaster.public_room.id
    user.broadcaster.user_follow_bcts.each do |user_follow_bct|
      user_follow_bct.user.device_tokens.each do |device|
        if device.device_type == 'ios'
          list_ios_tokens.push(device.device_token)
        elsif device.device_type == 'android'
          list_android_tokens.push(device.device_token)
        end
      end
    end
    if list_ios_tokens.count > 0
    	uri = URI.parse(Settings.url_notification+"/ios")
	    http = Net::HTTP.new(uri.host,uri.port)
		request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
	    request.body = {'title' => title, 'description' => description, 'room_id' => room_id, 'tokens' => list_ios_tokens}.to_json
		request["Content-Type"] = "application/json"
		http.request(request)
    end
    if list_android_tokens.count > 0
      	uri = URI.parse(Settings.url_notification+"/android")
	    http = Net::HTTP.new(uri.host,uri.port)
		request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
	    request.body = {'title' => title, 'description' => description, 'room_id' => room_id, 'tokens' => list_android_tokens}.to_json
		request["Content-Type"] = "application/json"
		http.request(request)
    end
  end
end