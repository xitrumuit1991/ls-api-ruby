class Api::V1::IndexController < Api::V1::ApplicationController
  include Api::V1::Authorize

  def index
    render plain: 'Livestar API Version 1.1.1'
  end

  def msisdn
  	msisdn = []
  	request.headers.each do |key, value|
  		msisdn << "#{key}: #{value}"
  	end
  	render json: msisdn, status: 200 and return
  end
end