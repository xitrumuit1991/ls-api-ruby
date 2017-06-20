class IndexController < ApplicationController
  include Api::V1::Mbuy
  
  protect_from_forgery :except => [:create_transaction_mbuy]

  def index
    render plain: 'Livestar v1'
  end

  def healthcheck
    logger.info("---------api check healthcheck---------")
    render json: { message: 'ok', service: "livestar api service", date: Time.now.strftime("%Y/%m/%d %H:%M") }, status: 200
  end
end