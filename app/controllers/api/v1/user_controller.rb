class Api::V1::UserController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, except: [:active, :activeFBGP, :getAvatar, :publicProfile]

  def profile
  end

  def publicProfile
    return head 400 if params[:id].nil?
    @user = User.find_by_id(params[:id])
  end

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

  def activeFBGP
    user = User.find_by_email(params[:email])
    if user.present?
      user.username     = params[:username]
      user.password     = params[:password]
      user.actived      = true
      user.active_date  = Time.now
      if user.valid?
        if user.save
          return head 200
        else
          render plain: 'System error !', status: 400
        end
      else
        render json: user.errors.messages, status: 400
      end
    else
      return head 404
    end
  end

  def update
    @user.name                 = params[:name]
    @user.birthday             = params[:birthday]
    @user.gender               = params[:gender]
    @user.address              = params[:address]
    @user.phone                = params[:phone]
    @user.facebook_link        = params[:facebook]
    @user.twitter_link         = params[:twitter]
    @user.instagram_link       = params[:instagram]
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

  def updateProfile
    if params[:new_password] != nil and params[:new_password].to_s.length >= 6 and @user.authenticate(params[:password]) != false 
      @user.password          = params[:new_password]
    end

    if (params[:name] != nil or params[:name] != '') and params[:name].to_s.length >= 6
      @user.name              = params[:name]
      @user.facebook_link     = params[:facebook]
      @user.twitter_link      = params[:twitter]
      @user.instagram_link    = params[:instagram]
      @user.birthday    = params[:birthday]
      if @user.valid?
        if @user.save
          return head 200
        else
          render plain: 'Hệ thống đang bị lổi, vui lòng làm lại lần nữa !', status: 400
        end
      else
        render json: @user.errors.messages, status: 400
      end
    else
      render plain: 'Tên Quá Ngắn ...', status: 400
    end
  end

  def expenseRecords
    giftLogs = @user.gift_logs
    @records = Array.new
    giftLogs.each do |giftLog|
      aryLog = OpenStruct.new({:id => giftLog.id, :name => giftLog.gift.name, :thumb => "#{request.base_url}#{giftLog.gift.image_url}", :quantity => giftLog.quantity, :cost => giftLog.cost.round(0), :total_cost => (giftLog.cost*giftLog.quantity).round(0), :created_at => giftLog.created_at})
      @records = @records.push(aryLog)
    end

    heartLogs = @user.heart_logs
    heartLogs.each do |heartLog|
      aryLog = OpenStruct.new({:id => heartLog.id, :name => "Tim", :thumb => "#{request.base_url}/assets/images/icon/car-icon.png", :quantity => heartLog.quantity, :cost => 0, :total_cost => 0, :created_at => heartLog.created_at})
      @records = @records.push(aryLog)
    end

    actionLogs = @user.action_logs
    actionLogs.each do |actionLog|
      aryLog = OpenStruct.new({:id => actionLog.id, :name => actionLog.room_action.name, :thumb => "#{request.base_url}#{actionLog.room_action.image_url}", :quantity => 1, :cost => actionLog.cost.round(0), :total_cost => actionLog.cost.round(0), :created_at => actionLog.created_at})
      @records = @records.push(aryLog)
    end

    loungeLogs = @user.lounge_logs
    loungeLogs.each do |loungeLog|
      aryLog = OpenStruct.new({:id => loungeLog.id, :name => "Ghế " + loungeLog.lounge, :thumb => "#{request.base_url}/assets/images/icon/car-icon.png", :quantity => 1, :cost => loungeLog.cost.round(0), :total_cost => loungeLog.cost.round(0), :created_at => loungeLog.created_at})
      @records = @records.push(aryLog)
    end
    @records = @records.sort{|a,b| b[:created_at] <=> a[:created_at]}
  end

  def uploadAvatar
    return head 400 if params[:avatar].nil?
    if @user.update(avatar: params[:avatar])
      return head 201
    else
      return head 401
    end
  end

  def uploadCover
    return head 400 if params[:cover].nil?
    if @user.update(cover: params[:cover])
      return head 201
    else
      return head 401
    end
  end

  def getAvatar
    begin
      @u = User.find(params[:id])
      if @u
        file_url = "public#{@u.avatar.square}"
        if FileTest.exist?(file_url)
          send_file file_url, type: 'image/png', disposition: 'inline'
        else
          send_file 'public/default/no-avatar.png', type: 'image/png', disposition: 'inline'
        end
      else
        send_file 'public/default/no-avatar.png', type: 'image/png', disposition: 'inline'
      end
    rescue
      send_file 'public/default/no-avatar.png', type: 'image/png', disposition: 'inline'
    end
  end

  def payments
  end

end
