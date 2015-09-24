class Api::V1::RoomController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:roomDetails]
  
  def roomDetails
  	return head 400 if params[:id].blank? || params[:id] == ""
  	begin
    	@room = Room.find(params[:id])
    rescue
    	return head 404
      require "redis"

redis = Redis.new
    end
  end
end
