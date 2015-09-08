class Api::V1::UserController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate
  
  def getProfile
    if @user.present?
      @horo = Horo.find_by_id(@user.horo_id)
    else
      return head 404
    end
  end

  def update
    @user.name                 = params[:name]
    @user.dob                  = params[:dob]
    @user.tob                  = params[:tob]
    @user.timezone             = params[:timezone]

    if @user.valid?
      if @user.save
        FindHoroscopeJob.perform_later(@user)
        return head 200
      else
        render plain: 'System error !', status: 400
      end
    else
      render json: @user.errors.messages, status: 400
    end
  end

  def updateAvatar
  end

  def uploadAvatar
    if @user.present?
      if @user.update(avatar: params[:avatar])
        return head 201
      else
        return head 401
      end
    else
      return head 404
    end
  end
  
end
