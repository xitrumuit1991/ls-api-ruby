require "redis"
class Api::V1::BroadcastersController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include YoutubeHelper

  before_action :authenticate, except: [:getFeatured, :getHomeFeatured, :search , :getRoomFeatured , :profile]
  before_action :checkIsBroadcaster, except: [:onair, :profile, :follow, :followed, :search, :getFeatured, :getHomeFeatured, :getRoomFeatured]

  def myProfile
  end

  def profile
    @broadcaster = Broadcaster.find(params[:id])
    @user = @broadcaster.user
    @fan = @broadcaster.rooms.find_by_is_privated(false).heart_logs.select('*, sum(quantity) as total').group('user_id').order('total desc').limit(10)
    # @followers = UserFollowBct.select('*,sum(top_user_send_gifts.quantity) as quantity, sum(top_user_send_gifts.quantity*top_user_send_gifts.money) as total_money').where(broadcaster_id: @broadcaster.id).joins('LEFT JOIN top_user_send_gifts on user_follow_bcts.broadcaster_id = top_user_send_gifts.broadcaster_id and user_follow_bcts.user_id = top_user_send_gifts.user_id LEFT JOIN users on user_follow_bcts.user_id = users.id').group('user_follow_bcts.user_id').order('total_money desc').limit(10)
  end

  def defaultBackground
    @images = RoomBackground.all
  end

  def broadcasterBackground
    @images = @user.broadcaster.broadcaster_backgrounds
  end

  def broadcasterRevcivedItems
    if @user.is_broadcaster
      giftLogs = @user.broadcaster.rooms.find_by_is_privated(false).gift_logs
      @records = Array.new
      giftLogs.each do |giftLog|
        aryLog = OpenStruct.new({:id => giftLog.id, :name => giftLog.gift.name, :thumb => "#{request.base_url}#{giftLog.gift.image.square}", :quantity => giftLog.quantity, :cost => giftLog.cost.round(0), :total_cost => (giftLog.cost*giftLog.quantity).round(0), :created_at => giftLog.created_at})
        @records = @records.push(aryLog)
      end

      heartLogs = @user.broadcaster.rooms.find_by_is_privated(false).heart_logs
      heartLogs.each do |heartLog|
        aryLog = OpenStruct.new({:id => heartLog.id, :name => "Tim", :thumb => "#{request.base_url}/assets/images/icon/car-icon.png", :quantity => heartLog.quantity, :cost => 0, :total_cost => 0, :created_at => heartLog.created_at})
        @records = @records.push(aryLog)
      end

      actionLogs = @user.broadcaster.rooms.find_by_is_privated(false).action_logs
      actionLogs.each do |actionLog|
        aryLog = OpenStruct.new({:id => actionLog.id, :name => actionLog.room_action.name, :thumb => "#{request.base_url}#{actionLog.room_action.image.square}", :quantity => 1, :cost => actionLog.cost.round(0), :total_cost => actionLog.cost.round(0), :created_at => actionLog.created_at})
        @records = @records.push(aryLog)
      end

      @records = @records.sort{|a,b| b[:created_at] <=> a[:created_at]}
    else
      render json: {error: t('error_not_bct')}, status: 400
    end
  end

  def status
    if params[:status].present?
      if @user.statuses.create(content: params[:status])
        return head 201
      else
        render json: {error: t('error_system')}, status: 400
      end
    else
      render json: {error: 'Vui lòng nhập trạng thái'}, status: 400
    end
  end

  def pictures
    if params[:pictures].present?
      @pictures = []
      params[:pictures].each do |picture|
        @pictures << @user.broadcaster.images.create({image: picture})
      end
    else
      render json: {error: t('error_empty_image') }, status: 400
    end
  end

  def deletePictures
    if params[:id].present?
      if @user.broadcaster.images.where(:id => params[:id]).present?
        if @user.broadcaster.images.where(:id => params[:id]).destroy_all
          return head 200
        else
          render json: {error: t('error_system')}, status: 400
        end
      else
        render json: {error: 'Không tồn tại ảnh này!'}, status: 400
      end
    else
      render json: {error: t('error_empty_image') }, status: 400
    end
  end

  def videos
    if params[:videos].present?
      @videos = []
      params[:videos].each do |key, video|
        id = youtubeID video[:link]
        link = 'https://www.youtube.com/embed/'+id
        @videos << @user.broadcaster.videos.create(({thumb: video['image'], video: link}))
      end
    else
      render json: {error: 'Vui lòng nhập video!' }, status: 400
    end
  end

  def deleteVideos
    if params[:id].present?
      if @user.broadcaster.videos.where(:id => params[:id]).present?
        if @user.broadcaster.videos.where(:id => params[:id]).destroy_all
          return head 200
        else
          render json: {error: t('error_system') }, status: 400
        end
      else
        render json: {error: 'Không tồn tại video này!'}, status: 400
      end
    else
      render json: {error: 'Vui lòng chọn video để xóa'}, status: 400
    end
  end

  def followed
    max_page = (Float( @user.broadcasters.count )/5).ceil
    if !params[:page].nil?
      if (params[:page].to_i + 1) > max_page
        params[:page] = max_page - 1
      end
    end
    offset = params[:page].nil? ? 0 : params[:page].to_i * 5
    @users_followed = @user.broadcasters.limit(5).offset(offset)
  end

  def follow
    if @user.user_follow_bcts.find_by_broadcaster_id(params[:id].to_i)
      if @user.user_follow_bcts.find_by_broadcaster_id(params[:id].to_i).destroy
        render plain: 'Unfollow !', status: 200
      else
        render json: {error: t('error_system'), bugs: @user.errors.full_messages}, status: 400
      end
    else
      if @user.user_follow_bcts.create(broadcaster_id: params[:id].to_i)
        render plain: 'Follow !', status: 201
      else
        render json: {error: t('error_system'), bugs: @user.errors.full_messages}, status: 400
      end
    end
  end

  def getFeatured
    @user = check_authenticate
    @totalUser = []
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    offset = params[:page].nil? ? 0 : params[:page].to_i * 4
    @featured = Featured.order(weight: :asc).limit(4).offset(offset)
    getAllRecord = Featured.all.length
    @totalPage =  (Float(getAllRecord)/4).ceil

    @featured.each do |f|
      @totalUser[f.broadcaster.public_room.id] = redis.hgetall(f.broadcaster.public_room.id).length
    end
  end

  def getHomeFeatured
    @featured = HomeFeatured.order(weight: :asc).limit(5)
  end
  
  def getRoomFeatured
    @user = check_authenticate
    @totalUser = []
    @featured = RoomFeatured.joins(broadcaster: :rooms).where('rooms.is_privated' => false).order('rooms.on_air desc, weight asc').limit(16)
    @featured.each do |f|
      if f.broadcaster.public_room.on_air
        redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
        @totalUser[f.broadcaster.public_room.id] = redis.hgetall(f.broadcaster.public_room.id).length
      end
    end
  end

  def search
    if params[:q].present?
      redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
      @totalUser = []
      @user = check_authenticate
      offset = params[:page].nil? ? 0 : params[:page].to_i * 10
      getAllRecord = Broadcaster.joins(:rooms, :user).select("broadcasters.*").where("username LIKE '%#{params[:q]}%' OR name LIKE '%#{params[:q]}%' OR fullname LIKE '%#{params[:q]}%' OR title LIKE '%#{params[:q]}%'").length
      @max_page = (Float(getAllRecord)/10).ceil
      @bcts = Broadcaster.joins(:rooms, :user).select("broadcasters.*").where("username LIKE '%#{params[:q]}%' OR name LIKE '%#{params[:q]}%' OR fullname LIKE '%#{params[:q]}%' OR title LIKE '%#{params[:q]}%'").limit(10).offset(offset)

      @bcts.each do |bct|
        if bct.public_room.present?
          @totalUser[bct.public_room.id] = redis.hgetall(bct.public_room.id).length
        end
      end
    else
      render json: {error: 'Vui lòng nhập từ khóa để tìm kiếm nhé!'}, status: 400
    end
  end

  def selectGift
    if params[:gift_id].present?
      gift_id = params[:gift_id].to_i
      type    = params[:type].to_s
      begin
        Gift::find(gift_id)
        if type == 'delete'
          if @user.broadcaster.public_room.bct_gifts.find_by(gift_id: gift_id).destroy
            return head 200
          else
            render json: {error: t('error'), bugs: @user.errors.full_messages}, status: 400
          end
        elsif type == 'select'
          if @user.broadcaster.public_room.bct_gifts.create(gift_id: gift_id)
            return head 200
          else
            render json: {error: t('error'), bugs: @user.errors.full_messages}, status: 400
          end
        else
          render json: {error: "Vui lòng chọn quà tặng nhé!"}, status: 400
        end
      rescue ActiveRecord::RecordNotFound
        render json: {error: "Quà tặng không tồn tại, Vui lòng xem lại quà tặng!"}, status: 404
      end
    else
      render json: {error: "Vui lòng chọn quà tặng nhé!"}, status: 400
    end
  end

  def selectAllGift
    if params[:type].to_s == 'delete'
     if @user.broadcaster.public_room.bct_gifts.destroy_all
      return head 200
     else
       render json: {error: t('error'), bugs: @user.errors.full_messages}, status: 400
     end
    elsif params[:type].to_s == 'select'
      @user.broadcaster.public_room.bct_gifts.destroy_all
      allGift = Gift.where(status: 1)
      allGift.each do |gift|
        @user.broadcaster.public_room.bct_gifts.create(gift_id: gift.id)
      end
      return head 200
    else
      render json: {error: t('error')}, status: 400
    end
  end

  def selectAction
    if params[:action_id].present?
      action_id = params[:action_id].to_i
      type = params[:type].to_s
      begin
        RoomAction::find(action_id)
        if type == 'delete'
          if @user.broadcaster.public_room.bct_actions.find_by(room_action_id: action_id).destroy
            return head 200
          else
            render json: {error: t('error'), bugs: @user.errors.full_messages}, status: 400
          end
        elsif type == 'select'
          if @user.broadcaster.public_room.bct_actions.create(room_action_id: action_id)
            return head 200
          else
            render json: {error: t('error'), bugs: @user.errors.full_messages}, status: 400
          end
        else
          render json: {error: "Vui lòng chọn hành động nhé!"}, status: 400
        end
      rescue ActiveRecord::RecordNotFound
        render json: {error: "Hành động không tồn tại, Vui lòng xem lại hành động!"}, status: 404
      end
    else
      render json: {error: "Vui lòng chọn hành động nhé!"}, status: 400
    end
  end

  def selectAllAction
    if params[:type].to_s == 'delete'
      if @user.broadcaster.public_room.bct_actions.destroy_all
        return head 200
      else
        render json: {error: t('error'), bugs: @user.errors.full_messages}, status: 400
      end
    elsif params[:type].to_s == 'select'
      @user.broadcaster.public_room.bct_actions.destroy_all
      allAction = RoomAction.where(status: 1)
      allAction.each do |action|
        @user.broadcaster.public_room.bct_actions.create(room_action_id: action.id)
      end
      return head 200
    else
      render json: {error: t('error')}, status: 400
    end
  end

  private
    def checkIsBroadcaster
      unless @user.is_broadcaster
        render json: {error: t('error_not_bct')}, status: 400
      end
    end

end