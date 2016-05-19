require 'rubygems'
require 'kraken-io'
require 'open-uri'

module KrakenHelper
  def optimizeKraken(fileParams)
    puts '======================='
    puts fileParams
    puts '======================='
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
end