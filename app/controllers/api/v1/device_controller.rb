class Api::V1::DeviceController < Api::V1::ApplicationController
  include Api::V1::Authorize
  before_action :authenticate, except: []

  def register
    device = DeviceToken.find_by_device_token(params[:device_token])
    if device.nil?
      DeviceToken.create(user_id: @user.id, device_token: params[:device_token], device_type: params[:type])
      return head 201
    else
      if device.user_id != @user.id
        device.user_id = @user.id
        device.save
      end
      return head 201
    end
  end
end