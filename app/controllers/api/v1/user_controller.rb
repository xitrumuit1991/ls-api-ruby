class Api::V1::UserController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:active, :activeByID]
  
  def active
    user = User.find_by_email(params[:email])
    if user.present?
      if params[:active_code].blank? || params[:active_code] == ""
        return head 400
      else
        if params[:active_code] == user.active_code
          user.update(active_date: Time.now, actived: true)
          return head 200
        else
          return head 400
        end
      end
    else
      return head 404
    end
  end

  def activeByID 
    user = User.find_by_email(params[:email])
    if user.present?
      if params[:id].blank? || params[:id] == ""
        return head 400
      else
        if user.fb_id == params[:id] || user.gp_id == params[:id]
          user.update(active_date: Time.now, actived: true)
          return head 200
        else 
          return head 400
        end
      end
    else
      return head 404
    end
  end

  def getProfile
    if !@user.present?
      return head 404
    end
  end

  def update
    @user.name                 = params[:name]
    @user.username             = params[:username]
    @user.birthday             = params[:birthday]
    @user.gender               = params[:gender]
    @user.address              = params[:address]
    @user.phone                = params[:phone]
    @user.cover                = params[:cover]
    if @user.valid?
      if @user.save
        return head 200
      else
        render plain: 'System error !', status: 400
      end
    else
      render json: @user.errors.messages, status: 400
    end
  end

  def uploadAvatar
    if @user.present?
      return head 400 if params[:avatar].nil?
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
