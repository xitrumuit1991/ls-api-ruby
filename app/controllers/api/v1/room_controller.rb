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
    getAllRecord = Room.where(on_air: true).length
    @totalPage =  (Float(getAllRecord)/9).ceil
  end

  def comingSoon
    @user = check_authenticate
    offset = params[:page].nil? ? 0 : params[:page].to_i * 9
    if params[:category_id].nil?
      getAllRecord = Schedule.joins(:room).where('rooms.on_air = false AND start > ?', DateTime.now).order(start: :asc, end: :asc).group(:room_id).length
      @schedules = Schedule.joins(:room).where('rooms.on_air = false AND start > ?', DateTime.now).order(start: :asc, end: :asc).group(:room_id).limit(9).offset(offset)
    else
      getAllRecord = Schedule.joins(:room).where('rooms.on_air = false AND rooms.room_type_id = ? AND start > ?', params[:category_id], DateTime.now).order(start: :asc, end: :asc).group(:room_id).length
      @schedules = Schedule.joins(:room).where('rooms.on_air = false AND rooms.room_type_id = ? AND start > ?', params[:category_id], DateTime.now).order(start: :asc, end: :asc).group(:room_id).limit(9).offset(offset)
    end
    @totalPage =  (Float(getAllRecord)/9).ceil
  end

  def roomType
    @room_types = RoomType.all
  end

  def getPublicRoom
    if @user.is_broadcaster
      @room = @user.broadcaster.rooms.order("is_privated DESC").first
      @backgrounds = RoomBackground.all
      @bct_backgrounds = BroadcasterBackground.where(broadcaster_id: @user.broadcaster.id)
      # get All gift
      @gifts = Gift.where(status: 1)

      # get All action
      @actions = RoomAction.where(status: 1)

      # Load selected gift
      gifts_selected = BctGift.where('room_id = ?', @room.id)
      @arrGiftSelected = []
      gifts_selected.each do |gift|
        @arrGiftSelected << gift.gift_id
      end

      # Load selected action
      @arrActionSelected = []
      actions_selected = BctAction.where('room_id = ?', @room.id)
      actions_selected.each do |action|
        @arrActionSelected << action.room_action_id
      end
    else
      render json: {error: 'Bạn không phải Idol, Hãy đăng ký để sử dụng chức năng này !'}, status: 400
    end
  end

  def detail
    if (params[:id].present?) && (params[:id].to_i.is_a? Integer)
      @user = check_authenticate
      if @user.nil?
        create_tmp_token
      end
      @room = Room.find(params[:id])

      if !@room.present?
        render json: {error: t('error_room_not_found')}, status: 404
      end
    else
      render json: {error: 'Vui lòng chọn phòng!'}, status: 400
    end
  end

  def detailBySlug
    if params[:slug].present?
      @user = check_authenticate
      if @user.nil?
        create_tmp_token
      end
      @room = Room.find_by_slug(params[:slug])
      if !@room.present?
        render json: {error: t('error_room_not_found')}, status: 404
      end
    else
      render json: {error: 'Vui lòng nhập slug'}, status: 400
    end
  end

  def updateSettings
    room = @user.broadcaster.rooms.find_by_is_privated(false)

    if room.present?
      if room.update(title: params[:title], room_type_id: params[:cat])
        @user.broadcaster.update(description: params[:bct_desc])
        return head 200
      else
        render json: {error: t('error'), bugs: room.errors.full_messages}, status: 400
      end
    else
      render json: {error: t('error_room_not_found')}, status: 404
    end
  end

  def uploadThumb
    if params[:thumb].present?
      room = @user.broadcaster.rooms.find_by_is_privated(false)

      if room.present?
        if room.update(thumb: params[:thumb])
          render json: {thumb: "#{request.base_url}#{room.thumb.thumb}?timestamp=#{room.updated_at.to_i}"}, status: 200
        else
          render json: {error: t('error')}, status: 400
        end
      else
        render json: {error: t('error_room_not_found')}, status: 404
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def thumbCrop
    if params[:thumb_crop].present?
      room = @user.broadcaster.rooms.find_by_is_privated(false)

      if room.present?
        if room.update(thumb_crop: params[:thumb_crop])
          render json: {thumb_crop: "#{request.base_url}#{room.thumb_crop}?timestamp=#{room.updated_at.to_i}"}, status: 200
        else
          render json: {error: t('error')}, status: 400
        end
      else
        render json: {error: t('error_room_not_found')}, status: 404
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def uploadBackground
    if params[:background].present?
      background = @user.broadcaster.broadcaster_backgrounds.create({image: params[:background]})
      render json: {id: background.id, image: "#{request.base_url}#{background.image.square}?timestamp=#{background.updated_at.to_i}"}, status: 201
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def deleteBackground
    if params[:background_id].present?
      if @user.broadcaster.broadcaster_backgrounds.where(:id => params[:background_id]).destroy_all
        return head 200
      else
        render json: {error: t('error_system')}, status: 400
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def changeBackground
    if params[:background_id].present?

      room = @user.broadcaster.rooms.find_by_is_privated(false)
      if room.present?
        room.update(broadcaster_background_id: params[:background_id])
        return head 200
      else
        render json: {error: t('error_room_not_found')}, status: 404
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def changeBackgroundDefault
    if params[:background_id].present?

      room = @user.broadcaster.rooms.find_by_is_privated(false)
      if room.present?
        room.update(broadcaster_background_id: nil,room_background_id: params[:background_id])

        return head 200
      else
        render json: {error: t('error_room_not_found')}, status: 404
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def updateSchedule
    if params[:schedule].present?
      room = @user.broadcaster.rooms.find_by_is_privated(false)

      if room.present?
        room.schedules.destroy_all

        if room.schedules.create(JSON.parse(params[:schedule].to_json))
          return head 201
        else
          render json: {error: t('error_system')}, status: 400
        end
      else
        render json: {error: t('error_room_not_found')}, status: 404
      end
    else
      render json: {error: 'Vui lòng nhập lịch diễn cho phòng'}, status: 400
    end
  end

  def deleteSchedule
    if params[:schedule_id].present?
      room = @user.broadcaster.rooms.find_by_is_privated(false)

      if room.present?
        begin
          room.schedules.find(params[:schedule_id].to_i).destroy
          return head 201
        rescue ActiveRecord::RecordNotFound => e
          render json: {error: 'Lịch diễn không tồn tại!, vui lòng thử lại nhé'}, status: 400
        end
      else
        render json: {error: t('error_room_not_found')}, status: 404
      end
    else
      render json: {error: 'Vui lòng chọn lịch diễn trước khi xóa nhé!'}, status: 400
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
    # @actions = RoomAction.where(status: 1)
    @bct_actions = BctAction.where('room_id = ? ',  params[:room_id].to_i)
  end

  def getGifts
    # @gifts = Gift.where(status: 1)
    @bct_gifts = BctGift.where('room_id = ?',  params[:room_id].to_i)
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
        render json: {error: t('error_not_bct')}, status: 400
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
