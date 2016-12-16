class Api::V1::BroadcastersController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include YoutubeHelper
  include KrakenHelper

  before_action :authenticate, except: [:getFeatured, :getHomeFeatured, :search , :getRoomFeatured , :profile]
  before_action :checkIsBroadcaster, except: [:onair, :profile, :follow, :followed, :search, :getFeatured, :getHomeFeatured, :getRoomFeatured]

  def myProfile
  end

  def profile
    @broadcaster = Broadcaster.find(params[:id])
    @user = @broadcaster.user
    @fan = @broadcaster.public_room.heart_logs.select('*, sum(quantity) as total').group('user_id').order('total desc').limit(10)
  end

  def defaultBackground
    @images = RoomBackground.all
  end

  def broadcasterBackground
    @images = @user.broadcaster.broadcaster_backgrounds
  end

  def giftLogs
    limit  = 5
    offset = params[:page].nil? ? 0 : params[:page].to_i * limit
    count  = @user.broadcaster.public_room.gift_logs.count
    @logs = @user.broadcaster.public_room.gift_logs.order(id: :desc).limit(limit).offset(offset)
    @total_money = @logs.to_a.sum(&:cost)
    # @total_money = GiftLog.where(id: @logs.pluck(:id)).sum("quantity * cost")
    @total_pages = (Float(count) / limit).ceil
  end

  def actionLogs
    limit  = 5
    offset = params[:page].nil? ? 0 : params[:page].to_i * limit
    count  = @user.broadcaster.public_room.action_logs.count
    @logs = @user.broadcaster.public_room.action_logs.order(id: :desc).limit(limit).offset(offset)
    @total_money = @logs.to_a.sum(&:cost)
    @total_pages = (Float(count) / limit).ceil
  end

  def loungeLogs
    limit  = 5
    offset = params[:page].nil? ? 0 : params[:page].to_i * limit
    count  = @user.broadcaster.public_room.lounge_logs.count
    @logs = @user.broadcaster.public_room.lounge_logs.order(id: :desc).limit(limit).offset(offset)
    @total_money = @logs.to_a.sum(&:cost)
    @total_pages = (Float(count) / limit).ceil
  end

  def broadcasterRevcivedItems
    if @user.is_broadcaster
      giftLogs = @user.broadcaster.public_room.gift_logs
      @records = Array.new
      giftLogs.each do |giftLog|
        aryLog = OpenStruct.new({
            :id => giftLog.id, 
            :name => giftLog.gift.name, 
            :thumb => "#{giftLog.gift.image_path[:image]}", 
            :thumb_w50h50 => "#{giftLog.gift.image_path[:image_w50h50]}", 
            :thumb_w100h100 => "#{giftLog.gift.image_path[:image_w100h100]}", 
            :thumb_w200h200 => "#{giftLog.gift.image_path[:image_w200h200]}", 
            :quantity => giftLog.quantity, 
            :cost => giftLog.cost.round(0), 
            :total_cost => (giftLog.cost*giftLog.quantity).round(0), 
            :created_at => giftLog.created_at
          })
        @records = @records.push(aryLog)
      end

      heartLogs = @user.broadcaster.public_room.heart_logs
      heartLogs.each do |heartLog|
        aryLog = OpenStruct.new({
            :id => heartLog.id, 
            :name => "Tim", 
            :thumb => nil, 
            :thumb_w50h50 => nil, 
            :thumb_w100h100 => nil, 
            :thumb_w200h200 => nil, 
            :quantity => heartLog.quantity, 
            :cost => 0, 
            :total_cost => 0, 
            :created_at => heartLog.created_at
          })
        @records = @records.push(aryLog)
      end

      actionLogs = @user.broadcaster.public_room.action_logs
      actionLogs.each do |actionLog|
        aryLog = OpenStruct.new({
            :id => actionLog.id, 
            :name => actionLog.room_action.name,
            :thumb => "#{actionLog.room_action.image_path[:image]}", 
            :thumb_w50h50 => "#{actionLog.room_action.image_path[:image_w50h50]}", 
            :thumb_w100h100 => "#{actionLog.room_action.image_path[:image_w100h100]}", 
            :thumb_w200h200 => "#{actionLog.room_action.image_path[:image_w200h200]}",
            :quantity => 1, :cost => actionLog.cost.round(0), 
            :total_cost => actionLog.cost.round(0), 
            :created_at => actionLog.created_at
          })
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
        picture = optimizeKraken(picture)
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
        if video['image'] != ''
          video['image'] = optimizeKraken(video['image'])
        else
          video['image'] = nil
        end
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
    offset = params[:page].nil? ? 0 : params[:page].to_i * 8
    @featured = Featured.order(weight: :asc).limit(8).offset(offset)
    getAllRecord = Featured.all.length
    @totalPage =  (Float(getAllRecord)/8).ceil

    @featured.each do |f|
      @totalUser[f.broadcaster.public_room.id] = $redis.hgetall(f.broadcaster.public_room.id).length
    end
  end

  def getHomeFeatured
    @featured = Rails.cache.fetch('home_featured')
  end

  def getRoomFeatured
    @user = check_authenticate
    @totalUser = []
    @featured = Rails.cache.fetch('room_featured')
    @featured.each do |f|
      if f.broadcaster.public_room.on_air
        @totalUser[f.broadcaster.public_room.id] = $redis.hgetall(f.broadcaster.public_room.id).length
      end
    end
  end

  def search
    if params[:q].present?
      @totalUser = []
      @user = check_authenticate
      limit = 12
      offset = params[:page].nil? ? 0 : params[:page].to_i * limit
      getAllRecord = Broadcaster.joins(:rooms, :user).select("broadcasters.*").where("username LIKE '%#{params[:q]}%' OR name LIKE '%#{params[:q]}%' OR fullname LIKE '%#{params[:q]}%' OR title LIKE '%#{params[:q]}%'").length
      @max_page = (Float(getAllRecord)/limit).ceil
      @bcts = Broadcaster.joins(:rooms, :user).select("broadcasters.*").where("username LIKE '%#{params[:q]}%' OR name LIKE '%#{params[:q]}%' OR fullname LIKE '%#{params[:q]}%' OR title LIKE '%#{params[:q]}%'").limit(limit).offset(offset)

      @bcts.each do |bct|
        if bct.public_room.present?
          @totalUser[bct.public_room.id] = $redis.hgetall(bct.public_room.id).length
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

  def reportTopHearter
    where = Hash.new
    where[:created_at] = params[:date].present? ? Time.parse(params[:date]).beginning_of_month..Time.parse(params[:date]).end_of_month : Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
    @total = @user.broadcaster.public_room.heart_logs.select('sum(quantity) as quantity').where(where).take.quantity.to_i
    @data = @user.broadcaster.public_room.heart_logs.select('user_id, sum(quantity) as quantity').where(where).group(:user_id).order('quantity DESC').limit(10)
  end

  def reportTopSpender
    where = Hash.new
    where[:created_at] = params[:date].present? ? Time.parse(params[:date]).beginning_of_month..Time.parse(params[:date]).end_of_month : Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
    @total = @user.broadcaster.public_room.user_logs.select('sum(money) as total').where(where).take.total.to_i
    @data = @user.broadcaster.public_room.user_logs.select('user_id, sum(money) as total').where(where).group(:user_id).order('total DESC').limit(10)
  end

  private
    def checkIsBroadcaster
      unless @user.is_broadcaster
        render json: {error: t('error_not_bct')}, status: 400
      end
    end

end