module YoutubeHelper
  def youtubeID(link)
    if link[/youtu\.be\/([^\?]*)/]
      $1
    else
      link[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      $5
    end
  end

  def youtubeThumb(id)
    return 'http://img.youtube.com/vi/' + id + '/hqdefault.jpg'
  end

end