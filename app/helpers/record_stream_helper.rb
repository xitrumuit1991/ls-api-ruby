module RecordStreamHelper
  def start_stream room
    $redis.set("stream_room_id:#{room.id}", {year: Time.now.year.to_s, month: Time.now.month.to_s, day: Time.now.day.to_s, hour: Time.now.hour.to_s+'_'+Time.now.min.to_s})
    linkRecode = "#{Settings.url_stream}#{room.id.to_s}&outputFile=#{room.id.to_s}_#{Time.now.year.to_s}_#{Time.now.month.to_s}_#{Time.now.day.to_s}_#{Time.now.hour.to_s+'_'+Time.now.min.to_s}.mp4&option=overwrite&action=startRecording"
    stream_logger = Logger.new("#{Rails.root}/log/StartStream.log")
    stream_logger.info("ANGCO DEBUG StartLinkRecode: #{linkRecode} \n")
    stream_logger.info("ANGCO DEBUG room: #{room} \n")
    recode linkRecode 
    return true
  end

  def end_stream room
    redis_stream = $redis.get("stream_room_id:#{room.id}")
    stream_logger = Logger.new("#{Rails.root}/log/StopStream.log")
    stream_logger.info("ANGCO DEBUG room: #{room} \n")
    stream_logger.info("ANGCO DEBUG room: #{redis_stream} \n")
    linkRecode = "#{Settings.url_stream}#{room.id.to_s}&outputFile=#{room.id.to_s}_#{redis_stream[:year]}_#{redis_stream[:month]}_#{redis_stream[:day]}_#{redis_stream[:hour]}.mp4&option=overwrite&action=startRecording"
    linkVideo = "#{Settings.url_video_stream}#{room.id.to_s}_#{redis_stream[:year]}_#{redis_stream[:month]}_#{redis_stream[:day]}_#{redis_stream[:hour]}.mp4/playlist.m3u8"
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
    http.request(request)
  end

  def add_vod(link, room)
    BctVideo.create(broadcaster_id: room.broadcaster.id, title: room.title + '_' + room.created_at.year + '' + room.created_at.month + '' + room.created_at.day , video: link, thumb: room.thumb_path.thumb_w160h190)
    videos = room.broadcaster.videos.order('created_at DESC')
    if videos.count > 5
      videos.last.delete
    end
  end
end