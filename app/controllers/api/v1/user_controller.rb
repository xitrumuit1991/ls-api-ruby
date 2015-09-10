class Api::V1::UserController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:active]
  
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

end
