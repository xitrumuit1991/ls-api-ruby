require "redis"
class Api::V1::RoomController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:onair, :comingSoon, :roomType, :detail, :detailBySlug, :getActions, :getGifts, :getLounges, :getThumb, :getThumbMb]
  before_action :checkIsBroadcaster, except: [:roomType, :onair, :comingSoon, :detail, :detailBySlug, :getActions, :getGifts, :getLounges, :getThumb, :getThumbMb]

  def onair
    @user = check_authenticate
    @totalUser = []
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    offset = params[:page].nil? ? 0 : params[:page].to_i * 9
    @rooms = Room.where(on_air: true).limit(9).offset(offset)
    @rooms.each do |room|
      @totalUser[room.id] = redis.hgetall(room.id).length
    end
    @getAllRecord = Room.where(on_air: true).length
    @totalPage =  (Float(@getAllRecord)/9).ceil
  end

  def comingSoon
    @user = check_authenticate
    offset = params[:page].nil? ? 0 : params[:page].to_i * 9
    if params[:category_id].nil?
      @getAllRecord = Schedule.joins(:room).where('rooms.on_air = false AND start > ?', DateTime.now).order(start: :asc, end: :asc).group(:room_id).length
      @schedules = Schedule.joins(:room).where('rooms.on_air = false AND start > ?', DateTime.now).order(start: :asc, end: :asc).group(:room_id).limit(9).offset(offset)
    else
      @getAllRecord = Schedule.joins(:room).where('rooms.on_air = false AND rooms.room_type_id = ? AND start > ?', params[:category_id], DateTime.now).order(start: :asc, end: :asc).group(:room_id).length      
      @schedules = Schedule.joins(:room).where('rooms.on_air = false AND rooms.room_type_id = ? AND start > ?', params[:category_id], DateTime.now).order(start: :asc, end: :asc).group(:room_id).limit(9).offset(offset)
    end
    @totalPage =  (Float(@getAllRecord)/9).ceil
  end

  def roomType
    @room_types = RoomType.all
  end

  def getPublicRoom
    if @user.is_broadcaster
      @room = @user.broadcaster.rooms.order("is_privated DESC").first
      @backgrounds = RoomBackground.all
      @bct_backgrounds = BroadcasterBackground.where(broadcaster_id: @user.broadcaster.id)
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
  end

  def detailBySlug
    return head 400 if params[:slug].nil?
    @user = check_authenticate
    if @user.nil?
      create_tmp_token
    end
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

  def thumbCrop
    return head 400 if params[:thumb_crop].nil?
    if @user.broadcaster.rooms.order("is_privated ASC").first.update(thumb_crop: params[:thumb_crop])
      render json: @user.broadcaster.rooms.order("is_privated ASC").first.thumb_crop, status: 200
    else
      return head 401
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

  def uploadBackgroundRoom
    return head 400 if params[:background].nil?
    background = @user.broadcaster.broadcaster_backgrounds.create({image: params[:background]})
    render json: background, status: 201
  end

  def deleteBackground
    return head 400 if params[:background_id].nil?
    if @user.broadcaster.broadcaster_backgrounds.where(:id => params[:background_id]).destroy_all
      return head 200
    end
  end

  def changeBackground
    return head 400 if params[:background_id].nil?
    if @user.broadcaster.rooms.find_by_is_privated(false).update(broadcaster_background_id: params[:background_id])
      return head 200
    else
      render plain: 'System error !', status: 400
    end
  end

  def changeBackgroundDefault
    return head 400 if params[:background_id].nil?
    if @user.broadcaster.rooms.find_by_is_privated(false).update(broadcaster_background_id: nil,room_background_id: params[:background_id])
      return head 200
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
    @actions = RoomAction.where(status: 1)
  end

  def getGifts
    @gifts = Gift.where(status: 1)
  end

  def getLounges
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    keys = redis.keys("lounges:#{params[:room_id]}:*")
    status = []
    12.times do |n|
      status[n] = {user: {id: 0, name: ''}, cost: 50}
    end
    keys.each do |key|
      split = key.split(':')
      status[split[2].to_i] = eval(redis.get(key))
    end
    render json: status, status: 200
  end

  def getThumb
    begin
      @room = Room.find(params[:id])
      if @room
        path_thumb_crop = "public#{@room.thumb_crop}"
        if FileTest.file?(path_thumb_crop)
          send_file path_thumb_crop, type: 'image/jpg', disposition: 'inline'
        elsif FileTest.file?("public#{@room.thumb.thumb}")
          send_file "public#{@room.thumb.thumb}", type: 'image/jpg', disposition: 'inline'
        else
          send_file 'public/default/room_setting_default.jpg', type: 'image/jpg', disposition: 'inline'
        end
      else
        send_file 'public/default/room_setting_default.jpg', type: 'image/jpg', disposition: 'inline'
      end
    rescue
      send_file 'public/default/room_setting_default.jpg', type: 'image/jpg', disposition: 'inline'
    end
  end

  def getThumbMb
    begin
      @room = Room.find(params[:id])
      if @room
        if FileTest.file?("public#{@room.thumb.thumb_mb}")
          send_file "public#{@room.thumb.thumb_mb}", type: 'image/jpg', disposition: 'inline'
        else
          send_file 'public/default/thumb_mb_default.jpg', type: 'image/jpg', disposition: 'inline'
        end
      else
        send_file 'public/default/thumb_mb_default.jpg', type: 'image/jpg', disposition: 'inline'
      end
    rescue
      send_file 'public/default/thumb_mb_default.jpg', type: 'image/jpg', disposition: 'inline'
    end
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
