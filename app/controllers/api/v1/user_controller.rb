class Api::V1::UserController < Api::V1::ApplicationController
  require "./lib/payments/paygates"
  require "./lib/payments/epaysms"
  include Api::V1::Authorize
  helper YoutubeHelper
  before_action :authenticate, except: [:active, :activeFBGP, :getAvatar, :publicProfile, :getBanner, :getProviders, :sms]

  def profile
  end

  def publicProfile
    return head 400 if params[:id].nil?
    @user = User.find_by_username(params[:id])
    @horoscope = horoscope(@user.birthday.zodiac_sign)
  end

  def horoscope(birthday)
    arr = {
      "Aries"       =>  "Bạch Dương",
      "Taurus"      =>  "Kim Ngưu",
      "Gemini"      =>  "Song Tử",
      "Cancer"      =>  "Cự Giải",
      "Leo"         =>  "Sư Tử",
      "Virgo"       =>  "Thất Nữ",
      "Libra"       =>  "Thiên Xứng",
      "Scorpio"     =>  "Thiên Yết",
      "Sagittarius" =>  "Nhân Mã",
      "Capricornus" =>  "Ma Kết",
      "Aquarius"    =>  "Bảo Bình",
      "Pisces"      =>  "Song Ngư"
    }
    return arr[birthday]
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
    if (params[:name] != nil or params[:name] != '') and params[:name].to_s.length >= 8 and params[:name].to_s.length <= 20
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

  def updatePassword
    if @user.authenticate(params[:password]) != false
      if (params[:new_password] != nil or params[:new_password] != '')  and params[:new_password].to_s.length >= 6
        @user.password = params[:new_password]
        if @user.valid?
          @user.save
          return head 200
        else
          render json: @user.errors.messages, status: 400
        end
      else
        render plain: 'Vui lòng nhập mật khẩu mới có độ dài tối thiểu là 6 kí tự', status: 400
      end
    else
      render plain: 'Mật khẩu hiện tại không đúng!', status: 400
    end
  end

  def expenseRecords
    giftLogs = @user.gift_logs
    @records = Array.new
    giftLogs.each do |giftLog|
      aryLog = OpenStruct.new({:id => giftLog.id, :name => giftLog.gift.name, :thumb => "#{request.base_url}#{giftLog.gift.image.square}", :quantity => giftLog.quantity, :cost => giftLog.cost.round(0), :total_cost => (giftLog.cost*giftLog.quantity).round(0), :created_at => giftLog.created_at})
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
      aryLog = OpenStruct.new({:id => loungeLog.id, :name => "Ghế " + loungeLog.lounge.to_s, :thumb => "#{request.base_url}/assets/images/icon/car-icon.png", :quantity => 1, :cost => loungeLog.cost.round(0), :total_cost => loungeLog.cost.round(0), :created_at => loungeLog.created_at})
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

  def avatarCrop
    return head 400 if params[:avatar_crop].nil?
    if @user.update(avatar_crop: params[:avatar_crop])
      render json: @user.avatar_crop, status: 200
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

  def coverCrop
    return head 400 if params[:cover_crop].nil?
    if @user.update(cover_crop: params[:cover_crop])
      render json: @user.cover_crop, status: 200
    else
      return head 401
    end
  end

  def getAvatar
    begin
      @u = User.find(params[:id])
      if @u
        file_url = "public#{@u.avatar_crop}"
        if FileTest.file?(file_url)
          send_file file_url, type: 'image/png', disposition: 'inline'
        elsif FileTest.file?("public#{@u.avatar.square}")
          send_file "public#{@u.avatar.square}", type: 'image/png', disposition: 'inline'
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

  def getBanner
    begin
      @u = User.find(params[:id])
      if @u
        file_url = "public#{@u.cover_crop}"
        if FileTest.file?(file_url)
          send_file file_url, type: 'image/jpg', disposition: 'inline'
        elsif FileTest.file?("public#{@u.cover.banner}")
          send_file "public#{@u.cover.banner}", type: 'image/jpg', disposition: 'inline'
        else
          send_file 'public/default/no-cover.jpg', type: 'image/jpg', disposition: 'inline'  
        end
      else
        send_file 'public/default/no-cover.jpg', type: 'image/jpg', disposition: 'inline'
      end
    rescue
      send_file 'public/default/no-cover.jpg', type: 'image/jpg', disposition: 'inline'
    end
  end

  def sms
    data = Ebaysms::Sms.new
    data.partnerid            = params[:partnerid]
    data.moid                 = params[:moid]
    data.userid               = params[:userid]
    data.shortcode            = params[:shortcode]
    data.keyword              = params[:keyword]
    data.content              = params[:content]
    data.transdate            = params[:transdate]
    data.checksum             = params[:checksum]
    data.amount               = params[:amount]
    data.smspPartnerPassword  = params[:smspPartnerPassword]
    checksum = data._checksum
  end

  def getProviders
    @providers = Provider::all
  end

  def payments
    # nha mang cung cap 
    m_UserName    = "charging01"
    m_Pass        = "gmwtwjfws"
    m_PartnerCode = "00477"
    m_PartnerID   = "charging01"
    m_MPIN        = "pajwtlzcb"

    webservice   = "http://charging-test.megapay.net.vn:10001/CardChargingGW_V2.0/services/Services?wsdl"
    soapClient = Savon.client(wsdl: webservice)
    m_Target = @user.username 

    cardCharging              = Paygate::CardCharging.new
    cardCharging.m_UserName   = m_UserName
    cardCharging.m_PartnerID  = m_PartnerID
    cardCharging.m_MPIN       = m_MPIN
    cardCharging.m_Target     = m_Target
    cardCharging.m_Card_DATA  = params[:serial].to_s + ":".to_s + params[:pin].to_s + ":".to_s + "0".to_s + ":".to_s + params[:provider].to_s
    cardCharging.m_Pass       = m_Pass
    cardCharging.soapClient   = soapClient
    transid                   = m_PartnerCode + Time.now.strftime("%Y%m%d%I%M%S")
    cardCharging.m_TransID    = transid

    cardChargingResponse = Paygate::CardChargingResponse.new
    cardChargingResponse = cardCharging.cardCharging
    if cardChargingResponse.status == 200
      card      = Card::find_by_price cardChargingResponse.m_RESPONSEAMOUNT.to_i
      info = { pin: params[:pin], provider: params[:provider], serial: params[:serial], coin: card.coin.to_s }
      if card_logs(cardChargingResponse, info)
        if update_coin(info[:coin])
          render plain: "Nạp tiền thành công.", status: 200
        else
          render plain: "Lổi hệ thống. Vui lòng liên hệ quản trị viên để được tư vấn.", status: 500
        end
      else
        render plain: "Đã nạp card nhưng không lưu được logs. Vui lòng liên hệ quản trị viên để được tư vấn.", status: 500
      end
    elsif cardChargingResponse.status == 400
      render plain: cardChargingResponse.message, status: 400
    else
      render plain: cardChargingResponse.message, status: 500
    end
  end

  private
    def card_logs(obj, info)
      provider  = Provider::find_by_name info[:provider]
      CartLog.create(user_id: @user.id, provider_id: provider.id, pin: info[:pin], serial: info[:serial], price: obj.m_RESPONSEAMOUNT.to_i, coin: info[:coin].to_i, status: 200)
    end
    def update_coin(coin)
      money = @user.money + coin.to_i
      if @user.update(money: money)
        return true
      else
        return false 
      end
    end
end