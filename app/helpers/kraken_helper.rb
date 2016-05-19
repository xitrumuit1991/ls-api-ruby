require 'rubygems'
require 'kraken-io'
require 'open-uri'
require 'RMagick'

module KrakenHelper
  def optimizeKraken(fileParams)
    kraken = Kraken::API.new(
      :api_key => Settings.kraken_key,
      :api_secret => Settings.kraken_secret
    )
    thumb = kraken.upload(fileParams.tempfile.path, 'lossy' => true)
    if thumb.success
      File.write(fileParams.tempfile.path, open(thumb.kraked_url).read, { :mode => 'wb' })
      return fileParams
    else
      return false
    end
  end
  # Image base 64
  def optimizeKrakenWeb(fileParams)
    file = File.new("/tmp/optimizeKraken.png", 'wb')
    file.write(Base64.decode64(fileParams['data:image/png;base64,'.length .. -1]))
    kraken = Kraken::API.new(
      :api_key => Settings.kraken_key,
      :api_secret => Settings.kraken_secret
    )
    thumb = kraken.upload(file.path, 'lossy' => true)
    if thumb.success
      File.write(file.path, open(thumb.kraked_url).read, { :mode => 'wb' })
      return file
    else
      return false
    end
  end
end