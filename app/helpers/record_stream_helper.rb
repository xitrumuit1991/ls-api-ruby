module RecordStreamHelper
  def start_stream room
    $redis.set("stream_room_id:#{room.id}", {year: Time.now.year.to_s, month: Time.now.month.to_s, day: Time.now.day.to_s, hour: Time.now.hour.to_s+'_'+Time.now.min.to_s})
    linkRecode = "http://stream.livestar.vn:8086/livestreamrecord?app=livestar-open&streamname=#{room.id.to_s}&outputFile=#{room.id.to_s}_#{Time.now.year.to_s}_#{Time.now.month.to_s}_#{Time.now.day.to_s}_#{Time.now.hour.to_s+'_'+Time.now.min.to_s}.mp4&option=overwrite&action=startRecording"
    stream_logger = Logger.new("#{Rails.root}/public/backups/StartStream.log")
    stream_logger.info("ANGCO DEBUG StartLinkRecode: #{linkRecode} \n")
    stream_logger.info("ANGCO DEBUG room: #{room} \n")
    recode linkRecode 
    return true
  end

  def end_stream room
    redis_stream = eval($redis.get("stream_room_id:#{room.id}"))
    stream_logger = Logger.new("#{Rails.root}/public/backups/StopStream.log")
    stream_logger.info("ANGCO DEBUG room: #{room} \n")
    stream_logger.info("ANGCO DEBUG room: #{redis_stream} \n")
    linkRecode = "http://stream.livestar.vn:8086/livestreamrecord?app=livestar-open&streamname=#{room.id.to_s}&outputFile=#{room.id.to_s}_#{redis_stream[:year]}_#{redis_stream[:month]}_#{redis_stream[:day]}_#{redis_stream[:hour]}.mp4&option=overwrite&action=startRecording"
    linkVideo = "http://stream.livestar.vn:80/livestar-vod/mp4:#{room.id.to_s}_#{redis_stream[:year]}_#{redis_stream[:month]}_#{redis_stream[:day]}_#{redis_stream[:hour]}.mp4/playlist.m3u8"
    stream_logger.info("ANGCO DEBUG StopLinkRecode: #{linkRecode} \n")
    stream_logger.info("ANGCO DEBUG room: #{linkVideo} \n")
    recode linkRecode 
    add_vod(linkVideo, room)
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

  def add_vod(link, room)
    BctVideo.create(broadcaster_id: room.broadcaster.id, video: link)
    videos = room.broadcaster.videos
    if videos.count > 5
      videos.order('created_at DESC').destroy_all
      videos.each do |video|
        BctVideo.create(broadcaster_id: video.broadcaster_id, video: video.video, thumb: video.thumb, created_at: video.created_at, updated_at: video.updated_at)
      end
    end
  end
end