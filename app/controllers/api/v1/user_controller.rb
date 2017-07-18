class Api::V1::UserController < Api::V1::ApplicationController
  require "./lib/payments/paygates"
  require "./lib/payments/epaysms"
  require "./lib/payments/magebanks"
  require "./lib/payments/megacards"
  include Api::V1::Authorize
  include KrakenHelper
  include CaptchaHelper
  helper YoutubeHelper
  before_action :authenticate, except: [:active, :activeFBGP, :getAvatar, :publicProfile, :getBanner, :getProviders, :sms, :getMegabanks, :getBanks, :checkRecaptcha, :confirmEbay, :real_avatar, :getSms, :countShare]

  def setMoneyForUser
    return render json: {error: 'error'}, status: 400 if params[:md5].blank?
    return render json: {error: 'error'}, status: 400 if params[:email].blank?
    return render json: {error: 'error'}, status: 400 if params[:md5] != '60a069a04f0efb21531c1e91f02b7e06'
    return render json: {error: 'error'}, status: 400 if Digest::MD5.hexdigest(params[:email]) != params[:md5]
    return render json: {error: 'error'}, status: 400 if Digest::MD5.hexdigest(params[:email]) != '60a069a04f0efb21531c1e91f02b7e06'
    money = params[:money].present? ? params[:money] : 100
    @user.money = @user.money.to_i+money.to_i
    if @user.save
    	return render json: @user.to_json, status: 200
  	end
  	return render json: {error: 'error'}, status: 400
  end



  def getNoHeart
    return render json: {message: 'Không lấy được thông tin user'}, status: 400 if @user.blank?
    if @user.present?
      return render json: {message: 'get heat of user OK', no_heart: @user.no_heart}, status: 200
    end
    return render json: {message: 'Hệ thống đang bận. Vui lòng thử lại sau.'}, status: 400
  end



  def getMoney
    return render json: {message: 'Không lấy được thông tin user'}, status: 400 if @user.blank?
    if @user.present?
      return render json: {message: 'get money of user OK', money: @user.money}, status: 200
    end
    return render json: {message: 'Hệ thống đang bận. Vui lòng thử lại sau.'}, status: 400
  end



  def profile
    vipInfo = nil
    if @user.present?
      if @user.user_has_vip_packages.present?
        if @user.user_has_vip_packages.find_by_actived(true).present?
          if @user.user_has_vip_packages.find_by_actived(true).vip_package.present?
            vipInfo = @user.user_has_vip_packages.find_by_actived(true).vip_package.vip
          else
            @vipInfo = vipInfo
          end
        end
        @vipInfo = vipInfo
      else
        @vipInfo = vipInfo
      end
    else
      render json: {message: 'Không lấy được thông tin user '}, status: 400
    end
    # @vipInfo = @user.user_has_vip_packages.find_by_actived(true).present? ? @user.user_has_vip_packages.find_by_actived(true).vip_package.vip : nil
  end



  def publicProfile
    if params[:username].present?
      @user = User.find_by_username(params[:username])
      if !@user.present?
        render json: {message: 'User không tồn tại'}, status: 400
      end
    else
      render json: {message: 'Vui lòng nhập username'}, status: 400
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
            render json: {message: 'Mã kích hoạt không hợp lệ !'} , status: 400
          end
        else
          render json: {message: 'Vui lòng nhập mã kích hoạt !'}, status: 400
        end
      else
        render json: {message: 'Tài khoản này đã được kích hoạt !'}, status: 400
      end
    else
      render json: {message: 'Tài khoản này không tồn tại !'}, status: 404
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
      return head 400
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
          :thumb => "#{actionLog.room_action.image_path[:image]}", 
          :thumb_w50h50 => "#{actionLog.room_action.image_path[:image_w50h50]}", 
          :thumb_w100h100 => "#{actionLog.room_action.image_path[:image_w100h100]}", 
          :thumb_w200h200 => "#{actionLog.room_action.image_path[:image_w200h200]}",
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
      send_file "public#{@u.avatar_crop.w60h60.url}", type: 'image/png', disposition: 'inline'
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
      checkCaptcha = eval(checkCaptcha(params[:key_megabank]))
      if checkCaptcha[:success]
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
          user.increaseMoney(megabanklog.megabank.coin)
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
    Rails.logger.info "+++++++++++++++++SMS++++++++++++++++++++++"
    Rails.logger.info "+++++++++++++++++SMS++++++++++++++++++++++"
    Rails.logger.info "+++++++++++++++++SMS++++++++++++++++++++++"
    params.each do |key,value|
      Rails.logger.info "Param #{key}: #{value}"
    end
    if !params[:moid]
      #MO lan 1 co: partnerid, userid(sdt), shortcode(dau so dich vu),keyword, content, amount, checksum
      #vidu http://sms.vn/receiverMO?partnerid=10001&userid=84979898989&shortcode=9029&keyword=TEST&content=TEST+NAP+username&amount=1000&checksum=a363146024efe6692080e402dfdf3f24
      Rails.logger.info "MO lan 1 (k co moid, MO lan 2 moi co moid -  mang viettel)"
      Rails.logger.info "SMS: tin nhan tu mang viettel"
      activecode = params[:content].split(' ')[2]
      Rails.logger.info "content: #{params[:content]}"
      Rails.logger.info "activecode: #{activecode}"
      checkUserHaveActiveCode = User::find_by_active_code(activecode)
      Rails.logger.info("checkUserHaveActiveCode=#{checkUserHaveActiveCode.to_json}")
      Rails.logger.info "amount: #{params[:amount].match(/[^0-9]/).nil?}"
      if checkUserHaveActiveCode.present? and params[:amount].match(/[^0-9]/).nil?
        Rails.logger.info("khong tim thay user co active_code=#{activecode}")
        return render plain: "1|noi dung hop le", status: 200 
      end
      return render plain: "0|noi dung khong hop le", status: 200
      
      #remove params[:subkeyword] by nguyentvk
    elsif params[:partnerid] and params[:moid] and params[:userid] and params[:shortcode] and params[:telcocode] and params[:keyword] and params[:content] and params[:transdate] and params[:checksum] and params[:amount] 
      #MO chinh 10 key: partnerid, moid, userid, shortcode, telcocode, keyword, content, transdate, checksum, amount
      Rails.logger.info "MO (co moid): tin nhan tu mang vina - mobi"
      partnerid                 = Settings.partnerid
      data                      = Ebaysms::Sms.new
      data.partnerid            = params[:partnerid]
      data.moid                 = params[:moid]
      data.userid               = params[:userid]
      data.shortcode            = params[:shortcode]
      data.telcocode            = params[:telcocode]
      data.keyword              = params[:keyword]
      data.content              = params[:content]
      data.transdate            = params[:transdate]
      data.checksum             = params[:checksum]
      data.amount               = params[:amount]
      data.partnerpass          = Settings.partnerpass
      checksum                  = data._checksum
      Rails.logger.info "-------MO checksum: #{checksum}"
      Rails.logger.info "-------MO partnerid: #{partnerid}"
      if params[:partnerid].to_s == partnerid and checksum 
        Rails.logger.info "checkmoid: #{_checkmoid(params[:moid])}"
        if _checkmoid(params[:moid])
          render plain: 'requeststatus=2', status: 200
        else
          str = data.confirm
          Rails.logger.info "user_controller; MT confirm: #{str}"
          if str.to_s == 'requeststatus=200'
            activecode = params[:content].split(' ')[2]
            Rails.logger.info "user of insert money; activecode=#{activecode}"
            if update_coin_sms(activecode, params[:moid], params[:userid], params[:shortcode], params[:keyword], params[:content], params[:transdate], params[:checksum], params[:amount])
              Rails.logger.info "SUCCESS insert log mbf OK"
              render plain: str, status: 200
            else
              Rails.logger.info "ERROR insert log mbf FAIL"
              update_coin_sms(activecode, params[:moid], params[:userid], params[:shortcode], params[:keyword], params[:content], params[:transdate], params[:checksum], params[:amount])
              #tai khoan khong ton tai hoac loi xay ra khi ghi log 
              # thay doi bang logs de ghi lai nhung tai khoan nap tien bi loi luon,
              #cung van tra ve status 200 nhung phai thay doi tin nhan lai cho khach hang de khach hang lien he admin ben livestar
              render plain: str, status: 200
            end
          else
            Rails.logger.info "response MT tu Epaysms= #{str}"
            Rails.logger.info "gui MT confirm qua Epaysms that bai, k + money, k +logs SMS "
            case str.to_s
            when "requeststatus=01"
              Rails.logger.info "-----01: Ghi nhận request thất bại, yêu cầu gửi lại."
            when "requeststatus=02"
              Rails.logger.info "-----02: Trùng mtId"
            when "requeststatus=03"
              Rails.logger.info "-----03: IP của đối tác không hợp lệ hoặc chưa được cấu hình trong hệ thống."
            when "requeststatus=04"
              Rails.logger.info "-----04: Không tìm thấy thông tin command code trên hệ thống."
            when "requeststatus=05"
              Rails.logger.info "-----05: Không tìm thấy service number trên hệ thống"
            when "requeststatus=06"
              Rails.logger.info "-----06: Hệ thống tạm thời gặp lỗi."
            when "requeststatus=07"
              Rails.logger.info "-----07: content của MT vượt quá 160 char."
            when "requeststatus=14"
              Rails.logger.info "-----14: Có tham số bị rỗng hoặc thiếu."
            when "requeststatus=17"
              Rails.logger.info "-----17: sai check sum"
            when "requeststatus=18"
              Rails.logger.info "-----18: sai định dạng MTID."
            when "requeststatus=19"
              Rails.logger.info "-----19: method không được hỗ trợ."
            when "requeststatus=20"
              Rails.logger.info "-----20: không tim thấy MO của MT này(trong trường hợp xử dụng method= mtReceiver)"
            end
            render plain: str, status: 200
          end
        end
      else
        #loi checksum
        Rails.logger.info(" Error checksum MO; checkSum = MD5(moid + shortcode + keyword + UrlEncode(content) + transdate + partnerpass(da md5 roi) )")
        render plain: 'requeststatus=17', status: 200
      end
    else
      Rails.logger.info("thieu 1 trong 10 key nay; [ partnerid, moid, userid, shortcode, telcocode, keyword, content, transdate, checksum, amount ]")
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



  # def megacards # thay bang function def cttCard
  #   logger = Logger.new("#{Rails.root}/log/production.log")
  #   # nha mang cung cap
  #   if params[:key_payment].blank?
  #     render json: {error: "Vui lòng kiểm tra Captcha", code: 1}, status: 400
  #     return
  #   end
  #   if params[:key_payment].present?
  #     checkCaptcha = eval(checkCaptcha(params[:key_payment]))
  #     if checkCaptcha.blank?
  #       render json: {error: "Vui lòng kiểm tra Captcha !", code: 2}, status: 400
  #       return
  #     end
  #     if checkCaptcha[:success]
  #       m_ws_url      = Settings.megacardWsUrl
  #       m_partnerId   = Settings.megacardPartnerId
  #       m_cardSerial  = params[:serial].to_s.delete(' ')
  #       m_cardPin     = params[:pin].to_s.delete(' ')
  #       m_telcoCode   = params[:provider]
  #       m_password    = Settings.megacardPassword
  #       m_targetAcc   = @user.username
  #       megaCardCharging  = Megacard::MegacardAPIServices.new
  #       megaCardCharging.m_ws_url       = m_ws_url
  #       megaCardCharging.m_partnerId    = m_partnerId
  #       megaCardCharging.m_cardSerial   = m_cardSerial
  #       megaCardCharging.m_cardPin      = m_cardPin
  #       megaCardCharging.m_telcoCode    = m_telcoCode
  #       megaCardCharging.m_targetAcc    = m_targetAcc
  #       megaCardCharging.m_password     = m_password
  #       response = megaCardCharging.charging
  #       if response.status == 200
  #         card      = Card::find_by_price response.m_RESPONSEAMOUNT.to_i
  #         card_logs = CartLog::find_by_user_id(@user.id)
  #         coin = card_logs.nil? ? card.coin + card.coin/100*50 : card.coin
  #         info = { pin: m_cardPin, provider: m_telcoCode, serial: m_cardSerial, coin: coin }
  #         if card_logs(response, info)
  #           @user.increaseMoney(info[:coin])
  #           render plain: response.message, status: 200
  #         else
  #           render plain: "Đã nạp card nhưng không lưu được logs. Vui lòng chụp màng hình và liên hệ quản trị viên để được tư vấn(transId: #{response.transId})", status: 500
  #         end
  #       else
  #         render plain: response.message, status: 400
  #       end
  #     else
  #       render plain: "Vui lòng kiểm tra Captcha", status: 400
  #     end
  #   else
  #     render plain: "Vui lòng kiểm tra Captcha", status: 400
  #   end
  # end




  def cttCard
  	# railsLogger = Logger.new("#{Rails.root}/log/production.log");
    Rails.logger.info("+++++++++++++++++++++++++++++++++++++++++");
    Rails.logger.info("+++++++++++++++++++++++++++++++++++++++++");
    Rails.logger.info("+++++++++++api/v1/users/mega-card++++++++");
    return render json: {message: "Vui lòng kiểm tra Captcha", code: 11, detail: 'Miss key_payment'}, status: 400 if params[:key_payment].blank?
    return render json: {message: "Thiếu provider card", code: 12, detail: 'Miss provider'}, status: 400 if params[:provider].blank?
    return render json: {message: "Thiếu pin card", code: 13, detail: 'Miss pin'}, status: 400 if params[:pin].blank?
    return render json: {message: "Thiếu serial card", code: 14, detail: 'Miss serial'}, status: 400 if params[:serial].blank?
    if params[:key_payment].present?
      checkCaptcha = eval(checkCaptcha(params[:key_payment]));
      Rails.logger.info("------------checkCaptcha= #{checkCaptcha.to_json}-----------------")
      return render json: {message: "Vui lòng kiểm tra Captcha !", code: 2, detail: 'Captcha google invalid'}, status: 400 if checkCaptcha.blank? or checkCaptcha[:success].blank? or checkCaptcha[:success] == false
      if checkCaptcha[:success] == true
        # nha mang cung cap
        webservice   = Settings.chargingWebservice #link wsdl login

        m_UserName    = Settings.chargingUsername
        m_Pass        = Settings.chargingPassword
        m_PartnerCode = Settings.chargingPartnerCode
        m_PartnerID   = Settings.chargingPartnerId
        m_MPIN        = Settings.chargingMpin

        soapClient = Savon.client(wsdl: webservice)
        m_Target = @user.username

        serial = params[:serial].to_s.delete(' ')
        pin = params[:pin].to_s.delete(' ')
        cardCharging              = Paygate::CardCharging.new
        cardCharging.m_UserName   = m_UserName
        cardCharging.m_Pass       = m_Pass
        cardCharging.m_PartnerID  = m_PartnerID
        cardCharging.m_MPIN       = m_MPIN
        cardCharging.m_Target     = m_Target
        cardCharging.m_Card_DATA  = serial + ":".to_s + pin + ":".to_s + "0".to_s + ":".to_s + params[:provider].to_s
        cardCharging.soapClient   = soapClient
        transid                   = m_PartnerCode + Time.now.strftime("%Y%m%d%I%M%S")
        cardCharging.m_TransID    = transid

        cardChargingResponse = Paygate::CardChargingResponse.new
        cardChargingResponse = cardCharging.cardCharging #thuc hien login & charge

        Rails.logger.info("---------result after call charge----------");
        Rails.logger.info("---------cardChargingResponse-----------------")
        Rails.logger.info("---------status=#{cardChargingResponse.status}");
      	Rails.logger.info("---------message=#{cardChargingResponse.message}");
      	Rails.logger.info("---------m_Status=#{cardChargingResponse.m_Status}");
      	Rails.logger.info("---------m_Message=#{cardChargingResponse.m_Message}");
      	Rails.logger.info("---------m_TRANSID=#{cardChargingResponse.m_TRANSID}");
      	Rails.logger.info("---------m_AMOUNT=#{cardChargingResponse.m_AMOUNT}");
      	Rails.logger.info("---------m_RESPONSEAMOUNT=#{cardChargingResponse.m_RESPONSEAMOUNT}");

        if cardChargingResponse.present? and cardChargingResponse.status == 400
        	Rails.logger.info("---------ERROR cardChargingResponse----------status == 400");
          return render json: {message: cardChargingResponse.message, detail: 'Nạp thẻ không thành công. Vui lòng thử lại.',  code: 5}, status: 400
        end
        if cardChargingResponse.present? and cardChargingResponse.status != 200
        	Rails.logger.info("---------ERROR cardChargingResponse----------status!=200");
          return render json: {message: cardChargingResponse.message, detail:  'Nạp thẻ không thành công. Vui lòng thử lại.' ,  code: 6}, status: 400
        end

        if cardChargingResponse.status == 200
          card      = Card::find_by_price(cardChargingResponse.m_RESPONSEAMOUNT.to_i)
          card_logs_db = CartLog::find_by_user_id(@user.id)
          coin = card_logs_db.nil? ? (card.coin + card.coin/100*50) : card.coin
          info = { pin: pin, provider: params[:provider], serial: serial, coin: coin }
          Rails.logger.info("------------Obj card insert db =#{info}-----------------")
          Rails.logger.info(info)
          Rails.logger.info("---------money before charge = #{@user.money}-----");
          if card_logs(cardChargingResponse, info)
            @user.increaseMoney(info[:coin])
            Rails.logger.info("---------money after charge = #{@user.money}-----");
            return render json: {message: "Nạp tiền thành công."}, status: 200
          else
          	Rails.logger.info("Đã nạp card nhưng không lưu được logs. Vui lòng chụp màn hình và liên hệ quản trị viên để được tư vấn.");
          	Rails.logger.info(@user.errors.full_messages);
            return render json: {message: "Đã nạp card nhưng không lưu được logs. Vui lòng chụp màng hình và liên hệ quản trị viên để được tư vấn.", code: 4, detail: @user.errors.full_messages}, status: 400
          end
        end
      end
    end
  end




  def getTradeHistory
    @trade = @user.user_has_vip_packages.order(created_at: :desc).limit(10)
  end

  def countShare
    if params[:room_id]
      render json: {number: FbShareLog.where('room_id = ?', params[:room_id]).count } , status: 200
    else
      render json: {message: 'Vui lòng kiểm tra lại!!!', detail: 'thieu param room_id'}, status: 400
    end
  end



  def shareFBReceivedCoin
    logger.info("--------------shareFBReceivedCoin----------------");
    return render json: {message: 'Thiếu accessToken từ facebook.'} , status: 400 if params[:accessToken].blank?
    return render json: {message: 'Thiếu param room_id.'}, status: 400 if params[:room_id].blank?
    graph = nil
    fb_id = nil
    # money = FbShareLog.where('user_id = ?', @user.id).count < 1 ? 5 : 0
    money = 5
    room = Room.find(params[:room_id])
    return render json: {message: 'Không lấy được thông tin phòng.'}, status: 400 if room.blank?
    return render json: {message: 'Phòng hiện tại đang đóng. Vui lòng thử lại sau.'}, status: 400 if room.present? and room.on_air == false
    begin
      graph = Koala::Facebook::API.new(params[:accessToken])
      profile = graph.get_object("me?fields=id,name,email,birthday,gender")
      fb_id = profile['id']
      if params[:post_id].blank? and graph.present?
        @user.increaseMoney(money) 
        fb_logs(nil, money, fb_id, room.id, nil)
        render json: {message: 'Chia sẽ lên tường nhà thành công.', money: @user.money, detail: 'Koala::Facebook::APIError can not get post_id from facebook'}, status: 200
        return
      end
      begin
        info = graph.get_object(params[:post_id])
        if FbShareLog.where('fb_id = ? AND room_id = ? AND created_at > ?', fb_id, room.id, Time.now.beginning_of_day).count > 0
          render json: {message: 'Bạn đã chia sẽ trước đó !', money: @user.money, info: info}, status: 200
          return
        elsif FbShareLog.where('user_id = ? AND room_id = ? AND created_at > ?', @user.id, room.id, Time.now.beginning_of_day).count < 1
          @user.increaseMoney(money)
          fb_logs(params[:post_id], money, fb_id, room.id, nil)
          render json: {message: 'Đã cộng tiền thành công!!!', money: @user.money, info: info}, status: 200
          return
        else
          render json: {message: 'Mỗi ngày chỉ được nhận xu một lần!!!', money: @user.money, info: info}, status: 400
          return
        end
      rescue Koala::Facebook::APIError => exc
        logger.info("----------ERROR 1: Koala::Facebook::APIError= #{exc.to_json}")
        @user.increaseMoney(money) 
        fb_logs(nil, money, fb_id, room.id, nil) 
        render json: {message: 'Chia sẽ lên tường nhà thành công.', money: @user.money, detail: 'Koala::Facebook::APIError can not get_object post_id', exc: exc}, status: 200
        return
      end
    rescue Koala::Facebook::APIError => exc
      logger.info("----------ERROR 2: Koala::Facebook::APIError= #{exc.to_json}")
      if graph.present?
        @user.increaseMoney(money) 
        fb_logs(nil, money, fb_id, room.id, nil) 
        render json: {message: 'Chia sẽ lên tường nhà thành công.', money: @user.money, detail: 'Koala::Facebook::APIError can not get post_id from facebook', exc: exc}, status: 200
        return
      end
      render json: {message: 'Bạn chưa chia sẽ lên tường nhà.', money: @user.money, detail: 'Koala::Facebook::APIError accessToken error', exc: exc}, status: 400
    end
  end




  def appShareFBReceivedCoin
    return render json: {message: 'thieu param device_id'}, status: 400 if params[:device_id].blank?
    return render json: {message: 'thieu param room_id'}, status: 400 if params[:room_id].blank?
    room = Room.find(params[:room_id])
    return render json: {message: 'Không tìm thấy phòng này.'}, status: 400 if room.blank? 
    return render json: {message: 'Không tìm thấy user đã share facebook.'}, status: 400 if @user.blank? 
    return render json: {message: 'Phòng hiện đang đóng. '}, status: 400 if room.present? and room.on_air == false
    # money = FbShareLog.where('user_id = ?', @user.id).count < 1 ? 20 : 10
    money = 5
    begin
      dvToken = DeviceToken.find_by_device_id(params[:device_id])
      return render json: {message: "Bạn phải cài app trước khi share!!!", detail: 'khong tim thay deviceToken trong db' } , status: 400 if dvToken.blank?
      if dvToken.present?
        if room.on_air
          fb_id = @user.fb_id
          if FbShareLog.where('device_id = ? AND room_id = ? AND created_at > ?', params[:device_id], room.id, Time.now.beginning_of_day).count > 10
            #1 device share qua 10 lan
            @user.increaseMoney(money)
            fb_logs(nil, money, fb_id, room.id, params[:device_id])
            render json: {message: "Đã cộng tiền thành công!!!", user_money: @user.money } , status: 200
          elsif FbShareLog.where('user_id = ? AND device_id = ? AND room_id = ? AND created_at > ?', @user.id, params[:device_id], room.id, Time.now.beginning_of_day).count < 1
            #user chua share room nay lan nao
            @user.increaseMoney(money)
            fb_logs(nil, money, fb_id, room.id, params[:device_id])
            render json: {message: "Đã cộng tiền thành công!!!", user_money: @user.money } , status: 200
          else
          	@user.increaseMoney(money)
            fb_logs(nil, money, fb_id, room.id, params[:device_id])
            render json: {message: "Đã cộng tiền thành công!!!", user_money: @user.money } , status: 200
          end
        end
      end
    rescue Exception => e
      return render json: {message: "Bạn chưa chia sẽ lên tường nhà!!!", detail: e  } , status: 400
    end
  end




  def userRevcivedCoin
    begin
      redeem = Redeem.where('code = ? AND start_date < ? AND end_date > ?', params[:code], DateTime.now, DateTime.now).take
      if redeem.present?
        redeem_log = RedeemLog.where(:user_id => @user.id, :redeem_id => redeem.id).take
        if redeem_log.nil?
          @user.increaseMoney(redeem.coin)
          redeemLog(redeem.id)
          render json: {message: "Đã cộng tiền thành công vào tài khoản của bạn!!!" } , status: 200
        else
          render json: {message: "Mỗi thành viên chỉ được nhận một lần!!!" } , status: 400
        end
      else
        render json: {message: "Mã chưa đúng hoặc sự kiện đã hết, vui lòng thử lại!!!" } , status: 400
      end
    rescue Exception => e
      render json: {message: "Đã gặp vấn đề trong việc kiểm tra mã, vui lòng hử lại!!!" } , status: 400
    end
  end

  private
	  def megabank_logs(info)
	    MegabankLog.create()
	  end


	  def card_logs(obj, info)
      if obj.present? and info.present?
  	    provider  = Provider::find_by_name info[:provider]
        if provider.present?
          Rails.logger.info("---------------insert log card----------");
          Rails.logger.info("---------------provider=#{provider}----------");
          CartLog.create(user_id: @user.id, provider_id: provider.id, pin: info[:pin], serial: info[:serial], price: obj.m_RESPONSEAMOUNT.to_i, coin: info[:coin].to_i, status: obj.status)
        else
          Rails.logger.info("---------------Can not insert log card; not found provider from db----------");
        end
      end
    end

	  def redeemLog(redeem_id)
	    RedeemLog.create(user_id: @user.id, redeem_id: redeem_id)
	  end

	  def _smslog(moid, userid, shortcode, keyword, content, transdate, checksum, amount, activecode)
	    @user_sms = User::find_by_active_code(activecode)
	    if @user_sms.present?
	      SmsLog.create(active_code: activecode, moid: moid, phone: userid, shortcode: shortcode, keyword: keyword, content: content, trans_date: transdate, checksum: checksum, amount: amount)
	    end
	  end

	  def fb_logs(post_id, coin, fb_id, room_id, device_id)
      post_id = 'can_not_get_from_fb' if post_id.blank?
	    FbShareLog.create(post_id: post_id, user_id: @user.id, coin: coin, fb_id: fb_id, room_id: room_id, device_id: device_id)
	  end

	  def update_coin_sms(activecode, moid, userid, shortcode, keyword, content, transdate, checksum, amount)
	    @user_sms = User::find_by_active_code(activecode)
      if @user_sms.blank?
        Rails.logger.info("ERROR khong tim thay user by(activecode) de insert log SMS")
        return false
      end
	    coin  = SmsMobile::find_by_price(amount.to_i)
      if coin.blank?
        Rails.logger.info("ERROR khong tim thay coin by amount de insert log SMS")
        return false
      end
	    if @user_sms.present? and coin.present?
        Rails.logger.info("SUCCESS before @user_sms=#{@user_sms.to_json}")
	      @user_sms.increaseMoney(coin.coin)
	      if _smslog(moid, userid, shortcode, keyword, content, transdate, checksum, amount, activecode)
          Rails.logger.info("SUCCESS coin=#{coin.to_json}")
	        Rails.logger.info("SUCCESS ghi log SMS thanh cong @user_sms=#{@user_sms.to_json}")
          return true
	      else
          Rails.logger.info("ERROR loi xay ra khi ghi log SMS")
	        return false
	      end
	    end
	  end

end