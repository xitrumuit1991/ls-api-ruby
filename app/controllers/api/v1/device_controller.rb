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

  def pushNotification
    list_tokens = []
    @user.broadcaster.user_follow_bcts.each do |user_follow_bct|
      user_follow_bct.user.device_tokens.each do |device|
        if device.device_type == params[:device_type]
          list_tokens.push(device.device_token)
        end
      end
    end
    if list_tokens.count > 0
      title = 'Idol '+@user.broadcaster.fullname+ ' xinh đẹp đang online, vào chém gió cùng Idol nào các bạn!'
      room_id = @user.broadcaster.public_room.id
      DeviceNotificationJob.perform_later(title, room_id, list_tokens)
    end
  end
end