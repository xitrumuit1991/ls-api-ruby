class Api::V1::IndexController < Api::V1::ApplicationController
  include Api::V1::Authorize

  def index
    render plain: 'Livestar API Version 1.1.0'
  end

  def msisdn
  	request.headers.each do |key, value|
  		Rails.logger.info "#{key}: #{value}"
  	end
  	render plain: "msisdn: #{request.headers['msisdn']} | #{request.headers['MSISDN']}", status: 200 and return
  end
end