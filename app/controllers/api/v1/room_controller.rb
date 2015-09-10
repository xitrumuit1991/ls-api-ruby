class Api::V1::RoomController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:roomDetails]
  
  def roomDetails
    @room = Room.find(params[:room_id])
  end
end
