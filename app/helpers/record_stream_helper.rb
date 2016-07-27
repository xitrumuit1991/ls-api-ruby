module RecordStreamHelper
  def start_stream room
    $redis.set("stream_room_id:#{room.id}", {year: Time.now.year.to_s, month: Time.now.month.to_s, day: Time.now.day.to_s, hour: Time.now.hour.to_s})
    linkRecode = "#{Settings.url_stream}#{room.id.to_s}&outputFile=#{room.id.to_s}_#{Time.now.year.to_s}_#{Time.now.month.to_s}_#{Time.now.day.to_s}_#{Time.now.hour.to_s}.mp4&option=overwrite&action=startRecording"
    Rails.logger.info "ANGCO DEBUG linkRecode: #{linkRecode}"
    Rails.logger.info "ANGCO DEBUG room: #{room}"
    recode linkRecode 
    return true
  end

  def end_stream room
    redis_stream = $redis.get("stream_room_id:#{room.id}")
    linkRecode = "#{Settings.url_stream}#{room.id}&outputFile=#{room.id}_#{redis_stream.year}_#{redis_stream.month}_#{redis_stream.day}_#{redis_stream.hour}.mp4&option=overwrite&action=startRecording"
    linkVideo = "#{Settings.url_video_stream}#{room.id}_#{redis_stream.year}_#{redis_stream.month}_#{redis_stream.day}_#{redis_stream.hour}.mp4/playlist.m3u8"
    Rails.logger.info "ANGCO DEBUG StopLinkRecode: #{linkVideo}"
    Rails.logger.info "ANGCO DEBUG room: #{room}"
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