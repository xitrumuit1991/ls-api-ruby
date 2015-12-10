class Api::V1::BroadcastersController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include YoutubeHelper

  before_action :authenticate, except: [:getFeatured, :getHomeFeatured, :search , :getRoomFeatured , :profile]
  before_action :checkIsBroadcaster, except: [:onair, :profile, :follow, :followed, :getFeatured, :getHomeFeatured, :search, :getRoomFeatured]

  resource_description do
    short 'Broadcaster (idol)'
  end

  def myProfile
  end

  api! "get full profile of broadcaster by their id"
  param :id, :number, :desc => "broadcaster's id", :required => true
  error :code => 401, :desc => "Unauthorized"
  example <<-EOS
    {
      id: 321,
      name: "Rainie Bui",
      birthday: "09/10/1991",
      horoscope: "Thien Binh",
      avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
      cover: "http://cdn.domain.com/broadcaters/bct-id/cover.jpg",
      heart: 1020,
      exp: 1231231,
      level: 10,
      facebook-link: "http://fb.me/whatthefuck",
      instagram-link: "...",
      twitter: "...",
      status: "This is updated status",
      description: "too long description...",
      photos: [ { id: 123123, link: "http://.../photo_1.jpg" }, ..],
      videos: [
        {
          id: 321654,
          thumb: "http://api.youtube.com/thumb/AbcXyZ",
          link: "http://youtube.com/AbcXyZ"
        },
        ...
      ],
      fans: [
        {id: 456, name: "Nacy babie", vip: "V1", heart: 253},
        ...
      ]
    }
  EOS
  def profile
    @broadcaster = Broadcaster.find(params[:id])
    @user = @broadcaster.user
    @followers = UserFollowBct.select('*,sum(top_user_send_gifts.quantity) as quantity, sum(top_user_send_gifts.quantity*top_user_send_gifts.money) as total_money').where(broadcaster_id: @broadcaster.id).joins('LEFT JOIN top_user_send_gifts on user_follow_bcts.broadcaster_id = top_user_send_gifts.broadcaster_id and user_follow_bcts.user_id = top_user_send_gifts.user_id LEFT JOIN users on user_follow_bcts.user_id = users.id').group('user_follow_bcts.user_id').order('total_money desc').limit(10)
  end

  def defaultBackground
    if @user.is_broadcaster
      @images = RoomBackground.all
    end
  end

  def broadcasterBackground
    if @user.is_broadcaster
      @images = @user.broadcaster.broadcaster_backgrounds
    end
  end

  def setDefaultBackgroundRoom
    return head 400 if params[:background_id].nil?
    if @user.broadcaster.rooms.order("is_privated DESC").first.update(room_background_id: params[:background_id].to_i)
      render json: {status: true}, status: 200
    else
      render json: @user.errors.messages, status: 400      
    end
  end

  def setBackgroundRoom
    return head 400 if params[:background_id].nil?
    if @user.broadcaster.rooms.order("is_privated DESC").first.update(broadcaster_background_id: params[:background_id].to_i)
      render json: {status: true}, status: 200
    else
      render json: @user.errors.messages, status: 400      
    end
  end

  def broadcasterRevcivedItems
    return head 400 if !@user.is_broadcaster
    giftLogs = @user.broadcaster.rooms.order("is_privated DESC").first.gift_logs
    @records = Array.new
    giftLogs.each do |giftLog|
      aryLog = OpenStruct.new({:id => giftLog.id, :name => giftLog.gift.name, :thumb => "#{request.base_url}#{giftLog.gift.image.square}", :quantity => giftLog.quantity, :cost => giftLog.cost.round(0), :total_cost => (giftLog.cost*giftLog.quantity).round(0), :created_at => giftLog.created_at})
      @records = @records.push(aryLog)
    end

    heartLogs = @user.broadcaster.rooms.order("is_privated DESC").first.heart_logs
    heartLogs.each do |heartLog|
      aryLog = OpenStruct.new({:id => heartLog.id, :name => "Tim", :thumb => "#{request.base_url}/assets/images/icon/car-icon.png", :quantity => heartLog.quantity, :cost => 0, :total_cost => 0, :created_at => heartLog.created_at})
      @records = @records.push(aryLog)
    end

    actionLogs = @user.broadcaster.rooms.order("is_privated DESC").first.action_logs
    actionLogs.each do |actionLog|
      aryLog = OpenStruct.new({:id => actionLog.id, :name => actionLog.room_action.name, :thumb => "#{request.base_url}#{actionLog.room_action.image.square}", :quantity => 1, :cost => actionLog.cost.round(0), :total_cost => actionLog.cost.round(0), :created_at => actionLog.created_at})
      @records = @records.push(aryLog)
    end

    @records = @records.sort{|a,b| b[:created_at] <=> a[:created_at]}
  end

  api! "post status"
  description "Broadcaster can post status to their timeline and latest status will display in room"
  param :status, String, :required => true
  error :code => 401, :desc => "Unauthorized"
  error :code => 400, :desc => "Can't save status"
  def status
    if @user.statuses.create(content: params[:status])
      return head 201
    else
      render plain: 'System error !', status: 400
    end
  end

  api! "Upload pictures"
  def pictures
    return head 400 if params.nil?
    pictures = []
    params[:pictures].each do |picture|
      pictures << @user.broadcaster.images.create({image: picture})
    end
    render json: pictures, status: 201
  end

  api! "Delete pictures"
  # param :pictures, :number, :desc => "array of picture's id", :required => true
  error :code => 401, :desc => "Unauthorized"
  error :code => 400, :desc => "can't delete picture"
  def deletePictures
    if @user.broadcaster.images.present?
      if @user.broadcaster.images.where(:id => params[:image_id]).destroy_all
        return head 200
      else
        return head 400
      end
    else
      return head 400
    end
  end

  api! "Create video"
  def videos
    return head 400 if params[:videos].nil?
    response_videos = []
    params[:videos].each do |key, video|
      id = youtubeID video[:link]
      link = 'https://www.youtube.com/embed/'+id
      response_videos << @user.broadcaster.videos.create(({thumb: video['image'], video: link}))
    end
    render json:response_videos, status: 201
  end

  api! "Delete videos"
  param :videos, :number, :desc => "array of video's id"
  error :code => 401, :desc => "Unauthorized"
  error :code => 400, :desc => "can't delete video"
  def deleteVideos
    if @user.broadcaster.videos.present?
      if @user.broadcaster.videos.where(:id => params[:id]).destroy_all
        return head 200
      else
        return head 400
      end
    else
      return head 400
    end
  end

  api! "Get all fans"
  description "Get all user followed current broadcaster"
  error :code => 401, :desc => "Unauthorized"
  example <<-EOS
    [
      {
        id: 321,
        name: "Rainie Bui",
        avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
        heart: 1020,
        exp: 12312,
        level: 10,
        status: ""
      },
      ...
    ]
  EOS
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

  api! "Follow broadcaster"
  param :id, :number, :desc => "broadcaster's id", :required => true
  error :code => 401, :desc => "Unauthorized"
  error :code => 400, :desc => "Can't follow"
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

  api! "get hot broadcaster"
  example <<-EOS
    [
      {
        id: 321,
        name: "Rainie Bui",
        nickname: "Zit",
        avatar: "http://cdn.domain.com/broadcaters/bct-id/avatar.jpg",
        heart: 1020,
        exp: 1231231,
        level: 10
      },
      ...
    ]
  EOS
  def getFeatured
    @featured = Featured.order(weight: :asc).limit(6)
  end

  api! "get sticked broadcaster in homepage"
  def getHomeFeatured
    @featured = HomeFeatured.order(weight: :asc).limit(5)
  end

  api! "get suggest broadcaster in room"
  def getRoomFeatured
    @featured = RoomFeatured.order(weight: :asc).limit(10)
  end

  def search
    return head 400 if params[:q].nil?
    offset = params[:page].nil? ? 0 : params[:page].to_i * 12
    @bcts = Broadcaster.joins(:rooms, :user).select("broadcasters.*").where("username LIKE '%#{params[:q]}%' OR name LIKE '%#{params[:q]}%' OR fullname LIKE '%#{params[:q]}%' OR title LIKE '%#{params[:q]}%'")
  end

  private
    def checkIsBroadcaster
      unless @user.is_broadcaster
        return head 400
      end
    end

end