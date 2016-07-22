class Api::V1::DeviceController < Api::V1::ApplicationController
  include Api::V1::Authorize
  before_action :authenticate, except: []

  def register
    device = DeviceToken.find_by_device_id(params[:device_id])
    if device.nil?
      DeviceToken.create(user_id: @user.id, device_id: params[:device_id], device_token: params[:device_token], device_type: params[:type])
      return head 201
    else
      if device.device_token != params[:device_token]
        device.device_token = params[:device_token]
      end
      if device.user_id != @user.id
        device.user_id = @user.id
      end
      device.device_type = params[:type]
      device.save
      return head 201
    end
  end
end