module RecordStreamHelper
  def start_stream room
    $redis.set("stream_room_id:#{room.id}", {year: Time.now.year.to_s, month: Time.now.month.to_s, day: Time.now.day.to_s, hour: Time.now.hour.to_s+'_'+Time.now.min.to_s})
    linkRecode = "http://stream.livestar.vn:8086/livestreamrecord?app=livestar-open&streamname=#{room.id.to_s}&outputFile=#{room.id.to_s}_#{Time.now.year.to_s}_#{Time.now.month.to_s}_#{Time.now.day.to_s}_#{Time.now.hour.to_s+'_'+Time.now.min.to_s}.mp4&option=overwrite&action=startRecording"
    stream_logger = Logger.new("#{Rails.root}/public/backups/StartStream.log")
    stream_logger.info("ANGCO DEBUG StartLinkRecode: #{linkRecode} \n")
    stream_logger.info("ANGCO DEBUG room: #{room} \n")
    stream_action linkRecode 
    return true
  end

  def end_stream room
    redis_stream = eval($redis.get("stream_room_id:#{room.id}"))
    stream_logger = Logger.new("#{Rails.root}/public/backups/StopStream.log")
    stream_logger.info("ANGCO DEBUG room: #{room} \n")
    stream_logger.info("ANGCO DEBUG room: #{redis_stream} \n")
    linkRecode = "http://stream.livestar.vn:8086/livestreamrecord?app=livestar-open&streamname=#{room.id.to_s}&outputFile=#{room.id.to_s}_#{redis_stream[:year]}_#{redis_stream[:month]}_#{redis_stream[:day]}_#{redis_stream[:hour]}.mp4&option=overwrite&action=stopRecording"
    linkVideo = "http://stream.livestar.vn:80/livestar-vod/mp4:#{room.id.to_s}_#{redis_stream[:year]}_#{redis_stream[:month]}_#{redis_stream[:day]}_#{redis_stream[:hour]}.mp4/playlist.m3u8"
    stream_logger.info("ANGCO DEBUG StopLinkRecode: #{linkRecode} \n")
    stream_logger.info("ANGCO DEBUG room: #{linkVideo} \n")
    stream_action linkRecode 
    add_vod(linkVideo, room, redis_stream)
    return true
  end

  def recode link
    uri = URI.parse(link)
    http = Net::HTTP.new(uri.host,uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth 'record', 'JmCpjEWHjcdO'
    response = http.request(request)
    stream_logger = Logger.new("#{Rails.root}/public/backups/Response.log")
    stream_logger.info("ANGCO DEBUG Response: #{response.to_yaml} \n")
    stream_logger.info("ANGCO DEBUG Link: #{link} \n")
  end
  
  def stream_action link
    digest_auth = Net::HTTP::DigestAuth.new
    uri = URI.parse link
    uri.user = 'record'
    uri.password = 'JmCpjEWHjcdO'
    http = Net::HTTP.new uri.host, uri.port
    req = Net::HTTP::Get.new uri.request_uri
    res = http.request req
    auth = digest_auth.auth_header uri, res['www-authenticate'], 'GET'
    req = Net::HTTP::Get.new uri.request_uri
    req.add_field 'Authorization', auth
    res = http.request req
  end

  def add_vod(link, room, time)
    BctVideo.create(broadcaster_id: room.broadcaster.id, title: "#{room.title} #{time[:hour]}h00 #{time[:day]}/#{time[:month]}/#{time[:year]}", video_type: 'vod', video: link, thumb: room.thumb_path[:thumb_w160h190])
    videos = room.broadcaster.videos.order('created_at DESC')
    if videos.count > 5
      videos.last.delete
    end
  end
end