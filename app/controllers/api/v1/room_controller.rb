class Api::V1::RoomController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:onair, :comingSoon]
  before_action :checkIsBroadcaster, except: [:onair, :comingSoon, :detail, :detailBySlug, :getActions, :getGifts, :getLounges]

  def onair
    @rooms = Room.where(on_air: true)
  end

  def comingSoon
    offset = params[:page].nil? ? 0 : params[:page] * 10
    if params[:category_id].nil?
      @schedules = Schedule.where('date > ? OR (date = ? AND start >= ?)', Time.now.strftime("%Y-%m-%d"), Time.now.strftime("%Y-%m-%d"), Time.now.strftime("%H:%M")).order(date: :asc, start: :asc).limit(10).offset(offset)
    else
      @schedules = Schedule.joins(:room).where('rooms.room_type_id = ? AND date > ? OR (date = ? AND start >= ?)', params[:category_id], Time.now.strftime("%Y-%m-%d"), Time.now.strftime("%Y-%m-%d"), Time.now.strftime("%H:%M")).order(date: :asc, start: :asc).limit(10).offset(offset)
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
    if Room.where("broadcaster_id = #{@user.broadcaster.id}").update_all(title: params[:title], room_type_id: params[:cat])
      return head 200
    else
      render plain: 'System error !', status: 400
    end
  end

  def uploadThumb
    return head 400 if params[:thumb].nil?
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
  end

  def uploadBackground
    return head 400 if params[:background].nil?
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
  end

  def changeBackground
    return head 400 if params[:background].nil?
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
  end

  def updateSchedule
    if room = Room.where("broadcaster_id = #{@user.broadcaster.id}").take
      schedules = JSON.parse(params[:schedule].to_json)
      if room.schedules.create(schedules)
        return head 201
      else
        render plain: 'System error !', status: 400
      end
    else
      render plain: 'System error !', status: 400
    end
  end

  def getActions
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    keys = redis.keys("actions:#{params[:room_id]}:*")
    @status = {}
    keys.each do |key|
      split = key.split(':')
      @status[split[2].to_i] = redis.get(key).to_i
    end
    @actions = RoomAction.all
  end

  def getGifts
    @gifts = Gift.all
  end

  def getLounges
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    keys = redis.keys("lounges:#{params[:room_id]}:*")
    status = []
    12.times do |n|
      status[n] = {user: {id: 0, name: ''}, cost: 0}
    end
    keys.each do |key|
      split = key.split(':')
      status[split[2].to_i] = eval(redis.get(key))
    end
    render json: status, status: 200
  end

  def topUserSendGift
    @top_gift_users = WeeklyTopUserSendGift.select('*,sum(quantity) as quantity, sum(money) as total_money').where(created_at: DateTime.now.prev_week.all_week).group(:broadcaster_id).order('quantity desc').limit(3)
  end

  private
    def checkIsBroadcaster
      unless @user.is_broadcaster
        return head 400
      end
    end

end
