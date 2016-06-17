class Api::V1::UserController < Api::V1::ApplicationController
  require "./lib/payments/paygates"
  require "./lib/payments/epaysms"
  require "./lib/payments/magebanks"
  include Api::V1::Authorize
  include KrakenHelper
  helper YoutubeHelper
  before_action :authenticate, except: [:active, :activeFBGP, :getAvatar, :publicProfile, :getBanner, :getProviders, :sms, :getMegabanks, :getBanks, :checkRecaptcha, :confirmEbay, :real_avatar, :getSms]

  def profile
    @vipInfo = @user.user_has_vip_packages.find_by_actived(true).present? ? @user.user_has_vip_packages.find_by_actived(true).vip_package.vip : nil
  end

  def publicProfile
    if params[:username].present?
      @user = User.find_by_username(params[:username])
      if !@user.present?
        render json: {error: 'User không tồn tại'}, status: 400
      end
    else
      render json: {error: 'Vui lòng nhập username'}, status: 400
    end
  end

  def active
    user = User.find_by_email(params[:email])
    if user.present?
      if user.actived == false
        if defined? params[:active_code] && !params[:active_code].blank?
          if params[:active_code] == user.active_code
            user.update(active_date: Time.now, actived: true)
            return head 200
          else
            render json: {error: 'Mã kích hoạt không hợp lệ !'} , status: 400
          end
        else
          render json: {error: 'Vui lòng nhập mã kích hoạt !'}, status: 400
        end
      else
        render json: {error: 'Tài khoản này đã được kích hoạt !'}, status: 400
      end
    else
      render json: {error: 'Tài khoản này không tồn tại !'}, status: 404
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
    @user.name              = params[:name]
    @user.birthday          = params[:birthday]

    # Optinal
    fb_link = params[:facebook]
    twitter_link = params[:twitter]
    instagram_link = params[:instagram]

    if !fb_link.to_s.empty?
      if fb_link.to_s.include?('http') || fb_link.to_s.include?('https')
        @user.facebook_link  = fb_link
      else
        @user.facebook_link  = 'https://' + fb_link
      end
    else
      @user.facebook_link = ''
    end


    if !twitter_link.to_s.empty?
      if twitter_link.to_s.include?('http') || twitter_link.to_s.include?('https')
        @user.twitter_link  = twitter_link
      else
        @user.twitter_link  = 'https://' + twitter_link
      end
    else
      @user.twitter_link = ''
    end

    if !instagram_link.to_s.empty?
      if instagram_link.to_s.include?('http') || instagram_link.to_s.include?('https')
        @user.instagram_link = instagram_link
      else
        @user.instagram_link = 'https://' + instagram_link
      end
    else
      @user.instagram_link = ''
    end

    if @user.valid?
      if @user.save
        return head 200
      else
        render json: {error: 'Hệ thống đang bị lổi, vui lòng làm lại lần nữa !'}, status: 400
      end
    else
      render json: {error: t('error'), bug: @user.errors.full_messages}, status: 400
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
          render json:{error: t('error') , bug: @user.errors.full_messages}, status: 400
        end
      else
        render json: {error: 'Vui lòng nhập mật khẩu mới có độ dài tối thiểu là 6 kí tự'}, status: 400
      end
    else
      render json: {error: 'Mật khẩu hiện tại không đúng!'}, status: 400
    end
  end

  def expenseRecords
    giftLogs = @user.gift_logs
    @records = Array.new
    giftLogs.each do |giftLog|
      aryLog = OpenStruct.new({
          :id => giftLog.id,
          :name => giftLog.gift.name,
          :thumb => "#{request.base_url}#{giftLog.gift.image_path[:image]}",
          :thumb_w50h50 => "#{request.base_url}#{giftLog.gift.image_path[:image_w50h50]}",
          :thumb_w100h100 => "#{request.base_url}#{giftLog.gift.image_path[:image_w100h100]}",
          :thumb_w200h200 => "#{request.base_url}#{giftLog.gift.image_path[:image_w200h200]}",
          :quantity => giftLog.quantity,
          :cost => giftLog.cost.round(0),
          :total_cost => (giftLog.cost*giftLog.quantity).round(0),
          :created_at => giftLog.created_at
        })
      @records = @records.push(aryLog)
    end

    heartLogs = @user.heart_logs
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

    actionLogs = @user.action_logs
    actionLogs.each do |actionLog|
      aryLog = OpenStruct.new({
          :id => actionLog.id,
          :name => actionLog.room_action.name,
          :thumb => "#{request.base_url}#{actionLog.room_action.image_path[:image]}", 
          :thumb_w50h50 => "#{request.base_url}#{actionLog.room_action.image_path[:image_w50h50]}", 
          :thumb_w100h100 => "#{request.base_url}#{actionLog.room_action.image_path[:image_w100h100]}", 
          :thumb_w200h200 => "#{request.base_url}#{actionLog.room_action.image_path[:image_w200h200]}",
          :quantity => 1,
          :cost => actionLog.cost.round(0),
          :total_cost => actionLog.cost.round(0),
          :created_at => actionLog.created_at
        })
      @records = @records.push(aryLog)
    end

    loungeLogs = @user.lounge_logs
    loungeLogs.each do |loungeLog|
      aryLog = OpenStruct.new({
          :id => loungeLog.id,
          :name => "Ghế " + loungeLog.lounge.to_s,
          :thumb => nil, 
          :thumb_w50h50 => nil, 
          :thumb_w100h100 => nil, 
          :thumb_w200h200 => nil,
          :quantity => 1,
          :cost => loungeLog.cost.round(0),
          :total_cost => loungeLog.cost.round(0),
          :created_at => loungeLog.created_at
        })
      @records = @records.push(aryLog)
    end
    @records = @records.sort{|a,b| b[:created_at] <=> a[:created_at]}
  end

  def uploadAvatar
    if params[:avatar].present?
      if @user.update(avatar: params[:avatar])
        return head 201
      else
        render json: {error: t('error_auth')}, status: 401
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def avatarCrop
    if params[:avatar_crop].present?
      params[:avatar_crop] = optimizeKrakenWeb(params[:avatar_crop])
      if @user.update(avatar_crop: params[:avatar_crop])
        render json: @user.avatar_crop, status: 200
      else
        render json: {error: t('error_auth')}, status: 401
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def uploadCover
    if params[:cover].present?
      if @user.update(cover: params[:cover])
        return head 201
      else
        render json: {error: t('error_auth')}, status: 401
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def coverCrop
    if params[:cover_crop].present?
      params[:cover_crop] = optimizeKrakenWeb(params[:cover_crop])
      if @user.update(cover_crop: params[:cover_crop])
        render json: @user.cover_crop, status: 200
      else
        render json: {error: t('error_auth')}, status: 401
      end
    else
      render json: {error: t('error_empty_image')}, status: 400
    end
  end

  def getAvatar
    begin
      @u = User.find(params[:id])
      send_file "#{@u.avatar_path[:avatar_w60h60]}", type: 'image/png', disposition: 'inline'
    rescue
      send_file 'public/default/w60h60_no-avatar.png', type: 'image/png', disposition: 'inline'
    end
  end

  def real_avatar
    if params[:id].present?
      begin
        @u = User.find(params[:id])
        avatar_path = @u.avatar.url ? "#{@u.avatar.url}" : "/default/no-avatar.png"
        render plain: "#{request.base_url}#{avatar_path}", status: 200 and return
      rescue ActiveRecord::RecordNotFound => e
        render plain: "#{request.base_url}/default/no-avatar.png", status: 200 and return
      end
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

  def internetBank
    # epay cung cap
    if params[:key_megabank].present?
      # checkCaptcha = eval(checkCaptcha(params[:key_megabank]))
      if true
        webservice    = Settings.magebankWS
        bank          = Bank.find_by_bankID(params[:bank_id])
        megabanklog   = MegabankLog.create(bank_id: bank.id, megabank_id: params[:megabank_id], user_id: @user.id)
        respUrl       = params[:respUrl] + "/" + megabanklog.id.to_s
        merchantid    = Settings.magebankMerchantid
        issuerID      = Settings.magebankIssuerID
        send_key      = Settings.magebankSend_key
        received_key  = Settings.magebankReceived_key
        soapClient    = Savon.client(wsdl: webservice)
        paramDeposit  = Megabanks::Service.new
        megabank      = Megabank.find(params[:megabank_id])
        paramDeposit.respUrl          = respUrl
        paramDeposit.merchantid       = merchantid
        paramDeposit.issuerID         = issuerID
        paramDeposit.send_key         = send_key
        paramDeposit.received_key     = received_key
        paramDeposit.soapClient       = soapClient
        paramDeposit.txnAmount        = megabank.price.to_s
        paramDeposit.fee              = "0"
        paramDeposit.userName         = @user.username
        paramDeposit.bankID           = params[:bank_id].to_s

        @result = paramDeposit._deposit
      else
        render json: {error: "Vui lòng kiểm tra Captcha" }, status: 400
      end
    else
      render json: {error: "Vui lòng kiểm tra Captcha" }, status: 400
    end
  end

  def confirmEbay
    responCode    = params[:responCode]
    if responCode == "00"
      megabanklog         = MegabankLog::find_by_id(params[:id])
      Rails.logger.info "ANGCO DEBUG megabanklog: #{megabanklog}"
      if !megabanklog.nil?
        transid             = params[:transid]
        megabanklog.transid = transid
        megabanklog.mac     = params[:mac]
        webservice          = Settings.magebankWS
        soapClient          = Savon.client(wsdl: webservice)
        paramConfirm                    = Megabanks::Service.new
        paramConfirm.responCodeConfirm  = responCode
        paramConfirm.merchantid         = Settings.magebankMerchantid
        paramConfirm.txnAmount          = megabanklog.megabank.price.to_s
        paramConfirm.transidConfirm     = transid
        paramConfirm.soapClient         = soapClient
        paramConfirm.send_key           = Settings.magebankSend_key
        @result                         = paramConfirm._confirm
        Rails.logger.info "ANGCO DEBUG result: #{@result}"
        @price                          = megabanklog.megabank.price.to_s
        @coin                           = megabanklog.megabank.coin.to_s
        Rails.logger.info "ANGCO DEBUG price: #{@price}"
        Rails.logger.info "ANGCO DEBUG coin: #{@coin}"
        if @result[:comfirm_response][:comfirm_result][:responsecode] == "00" && @result != false
          megabanklog.descriptionvn     = @result[:comfirm_response][:comfirm_result][:descriptionvn]
          megabanklog.descriptionen     = @result[:comfirm_response][:comfirm_result][:descriptionen]
          megabanklog.responsecode      = @result[:comfirm_response][:comfirm_result][:responsecode]
          megabanklog.status            = @result[:comfirm_response][:comfirm_result][:status]
          megabanklog.save
          user        = User.find(megabanklog.user_id)
          user.money  = user.money + megabanklog.megabank.coin
          user.save
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "01" && @result != false
          render json: {error: "Thất bại"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "02" && @result != false
          render json: {error: "Chưa confirm được"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "03" && @result != false
          render json: {error: "Đã confirm trước đó"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "04" && @result != false
          render json: {error: "Giao dịch Pending"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "05" && @result != false
          render json: {error: "Sai MAC"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "06" && @result != false
          render json: {error: "Không xác định mã lỗi"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "07" && @result != false
          render json: {error: "Giao dịch không tồn tại"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "08" && @result != false
          render json: {error: "Thông tin không đầy đủ"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "09" && @result != false
          render json: {error: "Đại lý không tồn tại"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "10" && @result != false
          render json: {error: "Sai định dạng"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "11" && @result != false
          render json: {error: "Sai thông tin"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "12" && @result != false
          render json: {error: "Ngân hàng tạm khóa hoặc không tồn tại"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "13" && @result != false
          render json: {error: "Có lỗi"}, status: 403
        elsif @result[:comfirm_response][:comfirm_result][:responsecode] == "14" && @result != false
          render json: {error: "Code không hợp lệ"}, status: 403
        else
          render json: {error: "confirm false"}, status: 403
        end
      else
        render json: {error: "Chưa ghi được lịch sử."}, status: 403
      end
    elsif responCode == "801"
      render json: {error: "Ngân hàng từ chối giao dịch"}, status: 403
    elsif responCode == "803"
      render json: {error: "Mã đơn vị không tồn tại"}, status: 403
    elsif responCode == "804"
      render json: {error: "Không đúng acces code"}, status: 403
    elsif responCode == "805"
      render json: {error: "Số tiền không hợp lệ"}, status: 403
    elsif responCode == "806"
      render json: {error: "Mã tiền tệ không tồn tại"}, status: 403
    elsif responCode == "807"
      render json: {error: "Lỗi không xác định"}, status: 403
    elsif responCode == "808"
      render json: {error: "Số thẻ không đúng"}, status: 403
    elsif responCode == "809"
      render json: {error: "Tên chủ thẻ không đúng"}, status: 403
    elsif responCode == "810"
      render json: {error: "Thẻ hết hạn/thẻ bị khóa"}, status: 403
    elsif responCode == "811"
      render json: {error: "Thẻ chưa đăng ký dịch vụ Internet banking"}, status: 403
    elsif responCode == "812"
      render json: {error: "Ngày phát hành/hết hạn không đúng"}, status: 403
    elsif responCode == "813"
      render json: {error: "Vượt quá hạn mức thanh toán"}, status: 403
    elsif responCode == "821"
      render json: {error: "Số tiền không đủ để thanh toán"}, status: 403
    elsif responCode == "899"
      render json: {error: "Người sử dụng cancel"}, status: 403
    elsif responCode == "901"
      render json: {error: "Merchant_code không hợp lệ"}, status: 403
    elsif responCode == "902"
      render json: {error: "Chuỗi mã hóa không hợp lệ"}, status: 403
    elsif responCode == "903"
      render json: {error: "Merchant_tran_id không hợp lệ"}, status: 403
    elsif responCode == "904"
      render json: {error: "Không tìm thấy giao dịch trong hệ thống"}, status: 403
    elsif responCode == "906"
      render json: {error: "Đã xác nhận trước đó"}, status: 403
    elsif responCode == "908"
      render json: {error: "Lỗi timeout xảy ra do không nhận thông điệp trả về"}, status: 403
    elsif responCode == "911"
      render json: {error: "Số tiền không hợp lệ"}, status: 403
    elsif responCode == "912"
      render json: {error: "Phí không hợp lệ"}, status: 403
    elsif responCode == "913"
      render json: {error: "Tax không hợp lệ"}, status: 403
    else
      render json: {error: "Link không hợp lệ"}, status: 403
    end
  end

  def sms
    Rails.logger.info "ANGCO DEBUG moid: #{defined? params[:moid]}"
    if !params[:moid]
      Rails.logger.info "ANGCO DEBUG SMS: mang viettel"
      activecode = params[:content].split(' ')[2]
      Rails.logger.info "ANGCO DEBUG content: #{params[:content]}"
      Rails.logger.info "ANGCO DEBUG activecode: #{activecode}"
      Rails.logger.info "ANGCO DEBUG _checkuser: #{_checkuser(activecode)}"
      Rails.logger.info "ANGCO DEBUG amount: #{params[:amount].match(/[^0-9]/).nil?}"
      if _checkuser(activecode) and params[:amount].match(/[^0-9]/).nil?
        render plain: "1| noi dung hop le", status: 200
      else
        render plain: "0| noi dung khong hop le", status: 200
      end
    elsif params[:partnerid] and params[:moid] and params[:userid] and params[:shortcode] and params[:keyword] and params[:content] and params[:transdate] and params[:checksum] and params[:amount] and params[:subkeyword]
      Rails.logger.info "ANGCO DEBUG SMS: mang vina - mobi"
      partnerid                 = Settings.partnerid
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
      data.partnerpass          = Settings.partnerpass
      checksum = data._checksum
      Rails.logger.info "ANGCO DEBUG checksum: #{checksum}"
      Rails.logger.info "ANGCO DEBUG partnerid: #{partnerid}"
      if params[:partnerid].to_s == partnerid and checksum 
        Rails.logger.info "ANGCO DEBUG checkmoid: #{_checkmoid(params[:moid])}"
        if _checkmoid(params[:moid])
          render plain: 'requeststatus=2', status: 200
        else
          str = data.confirm
          Rails.logger.info "ANGCO DEBUG confirm: #{str}"
          if str == "requeststatus=200"
            if update_coin_sms(params[:subkeyword], params[:moid], params[:userid], params[:shortcode], params[:keyword], params[:content], params[:transdate], params[:checksum], params[:amount])
              render plain: str, status: 200
            else
              update_coin_sms(params[:subkeyword], params[:moid], params[:userid], params[:shortcode], params[:keyword], params[:content], params[:transdate], params[:checksum], params[:amount])
              #tai khoan khong ton tai hoac loi xay ra khi ghi log # thai doi bang logs de ghi lai nhung tai khoan nap tien bi loi luon,
              #cung van tra ve status 200 nhung phai thay doi tin nhan lai cho khach hang de khach hang lien he admin ben livestar
              render plain: str, status: 200
            end
          else
            render plain: str, status: 200
          end
        end
      else
        #loi checksum
        render plain: 'requeststatus=17', status: 200
      end
    else
      render plain: 'requeststatus=400', status: 400
    end
  end

  def _checkuser(active_code)
    return !User::find_by_active_code(active_code).nil?
  end

  def _checkmoid(moid)
    return !SmsLog::find_by_moid(moid).nil?
  end

  def getProviders
    @providers = Provider::all
  end

  def getSms
    @sms = SmsMobile::all
  end

  def getBanks
    @banks = Bank::all
  end

  def getMegabanks
    @megabanks = Megabank::all
  end

  def payments
    if params[:key_payment].present?
      # checkCaptcha = eval(checkCaptcha(params[:key_payment]))
      if true
        # nha mang cung cap
        m_UserName    = Settings.chargingUsername
        m_Pass        = Settings.chargingPassword
        m_PartnerCode = Settings.chargingPartnerCode
        m_PartnerID   = Settings.chargingPartnerId
        m_MPIN        = Settings.chargingMpin

        webservice   = Settings.chargingWebservice

        soapClient = Savon.client(wsdl: webservice)
        m_Target = @user.username

        serial = params[:serial].to_s.delete('')
        pin = params[:pin].to_s.delete('')
        cardCharging              = Paygate::CardCharging.new
        cardCharging.m_UserName   = m_UserName
        cardCharging.m_PartnerID  = m_PartnerID
        cardCharging.m_MPIN       = m_MPIN
        cardCharging.m_Target     = m_Target
        cardCharging.m_Card_DATA  = serial + ":".to_s + pin + ":".to_s + "0".to_s + ":".to_s + params[:provider].to_s
        cardCharging.m_Pass       = m_Pass
        cardCharging.soapClient   = soapClient
        transid                   = m_PartnerCode + Time.now.strftime("%Y%m%d%I%M%S")
        cardCharging.m_TransID    = transid

        cardChargingResponse = Paygate::CardChargingResponse.new
        cardChargingResponse = cardCharging.cardCharging
        if cardChargingResponse.status == 200
          card      = Card::find_by_price cardChargingResponse.m_RESPONSEAMOUNT.to_i
          info = { pin: pin, provider: params[:provider], serial: serial, coin: card.coin.to_s }
          if card_logs(cardChargingResponse, info)
            @user.increaseMoney(info[:coin])
            render plain: "Nạp tiền thành công.", status: 200
          else
            render plain: "Đã nạp card nhưng không lưu được logs. Vui lòng liên hệ quản trị viên để được tư vấn.", status: 500
          end
        elsif cardChargingResponse.status == 400
          render plain: cardChargingResponse.message, status: 400
        else
          render plain: cardChargingResponse.message, status: 500
        end
      else
        render json: {error: "Vui lòng kiểm tra Captcha" }, status: 400
      end
    else
      render json: {error: "Vui lòng kiểm tra Captcha" }, status: 400
    end
  end

  def getTradeHistory
    @trade = @user.user_has_vip_packages.order(created_at: :desc).limit(10)
  end

  def shareFBReceivedCoin
    begin
      graph = Koala::Facebook::API.new(params[:accessToken])
      info = graph.get_object(params[:post_id])
      if !FbShareLog.where('user_id = ? AND created_at > ?', @user.id, Time.now.beginning_of_day).present?
        @user.increaseMoney(10)
        fb_logs(params[:post_id], 10)
        render plain: 'Đã cộng tiền thành công!!!', status: 200
      else
        render plain: 'Mỗi ngày chỉ được nhận xu một lần!!!', status: 400
      end
    rescue Exception => e
      render plain: 'Bạn chưa chia sẽ livestar.vn lên tường nhà!!!', status: 400
    end
  end

  private
  def megabank_logs(info)
    MegabankLog.create()
  end

  def card_logs(obj, info)
    provider  = Provider::find_by_name info[:provider]
    CartLog.create(user_id: @user.id, provider_id: provider.id, pin: info[:pin], serial: info[:serial], price: obj.m_RESPONSEAMOUNT.to_i, coin: info[:coin].to_i, status: 200)
  end

  def _smslog(moid, userid, shortcode, keyword, content, transdate, checksum, amount, subkeyword)
    @user_sms = User::find_by_active_code(subkeyword)
    if @user_sms.present?
      SmsLog.create(active_code: subkeyword, moid: moid, phone: userid, shortcode: shortcode, keyword: keyword, content: content, trans_date: transdate, checksum: checksum, amount: amount)
    end
  end

  def fb_logs(post_id, coin)
    FbShareLog.create(post_id: post_id, user_id: @user.id, coin: coin)
  end

  def update_coin_sms(subkeyword, moid, userid, shortcode, keyword, content, transdate, checksum, amount)
    @user_sms = User::find_by_active_code(subkeyword)
    coin  = SmsMobile::find_by_price(amount.to_i)
    money = @user_sms.money + coin.coin

    if @user_sms.present?
      @user_sms.increaseMoney(money)
      if _smslog(moid, userid, shortcode, keyword, content, transdate, checksum, amount, subkeyword)
        return true
      else
        # loi xay ra khi ghi log
        return false
      end
    else
      # tai khoan khong ton tai
      return false
    end
  end

end