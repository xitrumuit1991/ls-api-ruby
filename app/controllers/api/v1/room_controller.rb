class Api::V1::RoomController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:roomDetails]

  def onair
    @rooms = Room.where(on_air: true)
  end

  def comingSoon
    offset = params[:page].nil? ? 0 : params[:page] * 10
    if params[:category_id].nil?
      @schedules = Schedule.where('date >= ? AND end >= ?', Time.now.strftime("%Y-%m-%d"), Time.now.strftime("%H:%M")).order(date: :asc, start: :asc).limit(10).offset(offset)
    else
      @schedules = Schedule.joins(:room).where('rooms.room_type_id = ? AND date >= ? AND end >= ?', params[:category_id], Time.now.strftime("%Y-%m-%d"), Time.now.strftime("%H:%M")).order(date: :asc, start: :asc).limit(10).offset(offset)
    end
  end

  def detail
    return head 400 if params[:id].nil?
    @room = Room.find(params[:id])
  end

  def detailBySlug
    return head 400 if params[:slug].nil?
    @room = Room.find_by_slug(params[:slug])
  end

  def updateSettings
    return head 400 if params[:title].nil? || params[:cat].nil?
    if @user.is_broadcaster
      if Room.where("broadcaster_id = #{@user.broadcaster.id}").update_all(title: params[:title], room_type_id: params[:cat])
        return head 200
      else
        render plain: 'System error !', status: 400
      end
    else
      return head 400
    end
  end

  def uploadThumb
    return head 400 if params[:thumb].nil?
    if @user.is_broadcaster
      if room = Room.where("broadcaster_id = #{@user.broadcaster.id}").take
        room.thumb = params[:thumb]
        if room.save
          return head 200
        else
          render plain: 'System error !', status: 400
        end
      else
        render plain: 'System error !', status: 400
      end
    else
      return head 400
    end
  end

  def uploadBackground
    return head 400 if params[:background].nil?
    if @user.is_broadcaster
      if room = Room.where("broadcaster_id = #{@user.broadcaster.id}").take
        room.background = params[:background]
        if room.save
          return head 200
        else
          render plain: 'System error !', status: 400
        end
      else
        render plain: 'System error !', status: 400
      end
    else
      return head 400
    end
  end

  def changeBackground
    return head 400 if params[:background].nil?
    if @user.is_broadcaster
      if room = Room.where("broadcaster_id = #{@user.broadcaster.id}").take
        room.remote_background_url = params[:background]
        if room.save
          return head 200
        else
          render plain: 'System error !', status: 400
        end
      else
        render plain: 'System error !', status: 400
      end
    else
      return head 400
    end
  end

end
