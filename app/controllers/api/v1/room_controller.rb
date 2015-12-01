class Api::V1::RoomController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:onair, :comingSoon, :roomType, :detail, :detailBySlug, :getActions, :getGifts, :getLounges]
  before_action :checkIsBroadcaster, except: [:roomType, :onair, :comingSoon, :detail, :detailBySlug, :getActions, :getGifts, :getLounges]

  def onair
    offset = params[:page].nil? ? 0 : params[:page].to_i * 6
    @rooms = Room.where(on_air: true).limit(6).offset(offset)
  end

  def comingSoon
    offset = params[:page].nil? ? 0 : params[:page].to_i * 6
    if params[:category_id].nil?
      @schedules = Schedule.where('start < ? AND end > ?', DateTime.now+1, DateTime.now).order(start: :asc, end: :asc).limit(6).offset(offset)
    else
      @schedules = Schedule.joins(:room).where('rooms.room_type_id = ? AND start < ? AND end > ?', params[:category_id], DateTime.now+1, DateTime.now).order(start: :asc, end: :asc).limit(6).offset(offset)
    end
  end

  def roomType
    @room_types = RoomType.all
  end

  def getPublicRoom
    if @user.is_broadcaster
      @room = @user.broadcaster.rooms.order("is_privated DESC").first
    else
      render plain: 'Bạn không phải Broadcaster, Hãy đăng ký để sử dụng chức năng này !', status: 400
    end
  end

  def detail
    return head 400 if params[:id].nil?
    @user = check_authenticate
    if @user.nil?
      create_tmp_token
    end
    @room = Room.find(params[:id])
    puts '===================='
    puts !@user.broadcasters.where(id: @room.broadcaster.id).empty?
    puts '===================='
  end

  def detailBySlug
    return head 400 ? params[:slug].nil? : nil
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
    return head 400 if params[:room_thumb].nil?
    if @user.broadcaster.rooms.order("is_privated ASC").first.update(thumb: params[:room_thumb])
      render json: @user.broadcaster.rooms.order("is_privated ASC").first, status: 200
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
    if room = Room.where("broadcaster_id = #{@user.broadcaster.id} AND is_privated = 0").take
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
    return head 400 if params[:schedule].nil?
    @user.broadcaster.rooms.order("is_privated ASC").first.schedules.destroy_all
    if room = @user.broadcaster.rooms.order("is_privated ASC").first.schedules.create(eval(params[:schedule]))
      return head 201
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

  private
    def checkIsBroadcaster
      unless @user.is_broadcaster
        return head 400
      end
    end

    def create_tmp_token
      name = Faker::Name.name
      email = Faker::Internet.email(name)
      @tmp_user = TmpUser.create(email: email, name: name, exp: Time.now.to_i + 24 * 3600)
      @tmp_token = JWT.encode @tmp_user, Settings.hmac_secret, 'HS256'
      @tmp_user.token = @tmp_token
      @tmp_user.save
    end

end
