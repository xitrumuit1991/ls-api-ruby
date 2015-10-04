class Api::V1::BroadcastersController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate
  before_action :checkIsBroadcaster, except: [:onair]

  def myProfile
  end

  def profile
    @user = User.find(params[:id])
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
      if @user.broadcaster.images.where(:id => params[:pictures]).destroy_all
        return head 200
      else
        return head 400
      end
    else
      return head 400
    end
  end

  def videos
    videos = JSON.parse(params[:videos].to_json)
    if @user.broadcaster.videos.create(videos)
      return head 201
    else
      render plain: 'System error !', status: 400
    end
  end

  def deleteVideos
    if @user.broadcaster.videos.present?
      if @user.broadcaster.videos.where(:id => params[:videos]).destroy_all
        return head 200
      else
        return head 400
      end
    else
      return head 400
    end
  end

  def followed
    @users_followed = UserFollowBct.where(broadcaster_id: @user.broadcaster.id)
  end

  def follow
    if @user.user_follow_bcts.find_by_broadcaster_id(params[:id].to_i)
      if @user.user_follow_bcts.find_by_broadcaster_id(params[:id].to_i).destroy
        return head 200
      else
        return head 400
      end
    else
      if @user.user_follow_bcts.create(broadcaster_id: params[:id].to_i)
        return head 201
      else
        return head 400
      end
    end    
  end

  private
    def checkIsBroadcaster
      unless @user.is_broadcaster
        return head 400
      end
    end

end
