class Api::V1::BroadcastersController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate
  before_action :checkIsBroadcaster

  def profile
  end

  def status
    if @user.statuses.create(content: params[:status])
      return head 201
    else
      render plain: 'System error !', status: 400
    end
  end

  def pictures
    return head 400 if params.nil?
    params[:pictures].each do |picture|
      if @user.broadcaster.images.create({image: picture})
        errors = 201
      else
        errors = 401
      end
    end
    return head errors
  end

  def deletePictures
    if @user.broadcaster.images.present?
      puts '========================='
      puts params[:pictures]
      puts '========================='
      # if @user.broadcaster.images.where(:id => params[:]).destroy_all
      return head 200
    else
      return head 400
    end
  end

  private
    def checkIsBroadcaster
      unless @user.is_broadcaster
        return head 400
      end
    end

end
