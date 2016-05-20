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

  def uploadDowload(url)
    kraken = Kraken::API.new(
      :api_key => Settings.kraken_key,
      :api_secret => Settings.kraken_secret
    )
    thumb = kraken.url(url, 'lossy' => true)
    Rails.logger.info "ANGCO DEBUG Kraken: #{thumb}"
    if thumb.success
      Rails.logger.info "ANGCO DEBUG Kraken: #{thumb.kraked_url}"
      file = File.new("/tmp/avatar.png", 'wb')
      File.write(file, open(thumb.kraked_url).read, { :mode => 'wb' })
      return file
    else
      Rails.logger.info "ANGCO DEBUG Kraken: #{thumb.message}"
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