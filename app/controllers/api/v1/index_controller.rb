class Api::V1::IndexController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include Api::V1::Mbuy

  def index
    render plain: 'Livestar API Version 1.1.0'
  end

  def msisdn
  	msisdn = []
  	request.headers.each do |key, value|
  		msisdn << "#{key}: #{value}"
  	end
  	render json: msisdn, status: 200 and return
  end

  def mbuy
    render plain: create_cp_transaction(params[:isdn], params[:amount])
  end
end