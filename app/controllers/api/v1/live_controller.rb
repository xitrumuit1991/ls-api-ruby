  class Api::V1::LiveController < Api::V1::ApplicationController
    include Api::V1::Authorize
    include Api::V1::CacheHelper
    include RecordStreamHelper

    before_action :authenticate, :is_subscribed, except: [:forceEnd]
    before_action :is_started, except: [:sendMessage, :startRoom, :getUserList, :kickUser, :forceEnd, :addHeartInRoom]
    before_action :check_permission, only: [:startRoom, :endRoom, :doneAction, :kickUser]

    def getUserList
      render json: @user_list
    end

    def addHeartInRoom
      return render json: {message: 'Không lấy được thông tin phòng'}, status: 400 if @room.blank?
      return render json: {message: 'Phòng này chưa bắt đầu!'}, status: 400 if @room.present? and @room.on_air == false
      user_heart = UserReceivedHeart.find_by_user_id(@user.id) || UserReceivedHeart.create(:user_id => @user.id,:hearts => 1)
      if (DateTime.now.to_i - user_heart.updated_at.to_i) >= Settings.timeAddHeart
        begin
          user_heart.update(:hearts => user_heart.hearts.to_i + 1)
          @user.update(:no_heart => @user.no_heart.to_i + 1)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          $emitter.of('/room').in(@room.id).emit('add hearts', {hearts: @user.no_heart, sender: user})
          render json: {message: 'add heart cho user trong room thanh cong' }, status: 200 
          return
          # return head 200
        rescue => e
          render json: {message: e.message}, status: 400
          return
        end
      end
      return render json: {message: 'chưa đủ thời gian để add heart cho user' }, status: 200 
      # return head 200
    end


    

    def sendMessage
      # logger = Logger.new("#{Rails.root}/log/socket_production.log")
      # logger.info("-----------------------------------");
      # logger.info("---------socket emitter= #{$emitter}");
      # logger.info("---------Settings.redis_host= #{Settings.redis_host}");
      # logger.info("---------Settings.redis_port= #{Settings.redis_port}");
      message = params[:message]
      room_id = params[:room_id]
      vip_weight = @token_user['vip']
      vip = fetch_vip vip_weight
      no_char = vip ? vip['no_char'].to_i : 40
      if message.blank?
        render json: {error: 'Vui lòng nhập nội dung chat trước khi gởi !'}, status: 400
        return
      end
      if room_id.blank?
        render json: {error: 'Thiếu tham số room_id !'}, status: 400
        return
      end
      if message.present? and message.length > 0
        if message.length <= no_char
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          vip_data = vip_weight ? {vip: vip_weight} : 0
          $emitter.of('/room').in(room_id).emit('message', {message: message, sender: user, vip: vip_data, namespace: '/room'});
          render json: {message: "Send message thành công !", sender: user, messageData: message}, status: 201
          return
        else
          render json: {error: "Nội dung chat không được vượt quá #{no_char} kí tự !"}, status: 400
        end
      else
        render json: {error: 'Vui lòng nhập nội dung chat trước khi gởi !'}, status: 400
      end
    end




    def sendScreenText
      cost = 1
      message = params[:message]
      if @user.money >= cost then
        begin
          @user.decreaseMoney(cost)
          @user.increaseExp(10)
          @room.broadcaster.increaseExp(10)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username }
          $emitter.of('/room').in(@room.id).emit('screen text', { message: message, sender: user })

          # insert log
          @user.screen_text_logs.create(room_id: @room.id, content: message, cost: cost)
          UserLogJob.perform_later(@user, @room.id, cost)
          return render json: {message: 'send screen text OK' }, status: 201
          # return head 201
        rescue => e
          render json: {error: e.message}, status: 400
        end
      else
        render json: {error: 'Bạn không có đủ tiền'}, status: 403
      end
    end



    def voteAction
      return render json: {message: 'Thieu action_id'}, status: 400 if params[:action_id].blank?
      action_id = params[:action_id]
      db_action = fetch_action action_id
      return render json: {message: 'Khong get duoc actionDetail by action_id'}, status: 400 if db_action.blank?
      if db_action
        redis_action = $redis.get("actions:#{@room.id}:#{action_id}").to_i
        $redis.lock_for_update("actions:#{@room.id}:#{action_id}") do
          if redis_action < db_action['max_vote']
            begin
              @user.decreaseMoney(db_action['price'])
              new_value = redis_action + 1
              percent = new_value * 100 / db_action['max_vote']
              $redis.incr("actions:#{@room.id}:#{action_id}")

              @user.increaseExp(db_action['price'])
              if @room.broadcaster.present?
                @room.broadcaster.increaseExp(db_action['price'] * 10)
              end
              user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
              if db_action['max_vote'] <= new_value
                $emitter.of('/room').in(@room.id).emit('action full', {id: action_id, price: db_action['price'], voted: new_value, percent: percent, sender: user})
              else
                $emitter.of('/room').in(@room.id).emit('action recived', {id: action_id, price: db_action['price'], voted: new_value, percent: percent, sender: user})
              end

              # insert log
              ActionLogJob.perform_later(@user, @room.id, action_id, db_action['price'])
              UserLogJob.perform_later(@user, @room.id, db_action['price'])
              return render json: {message: 'Vote thành công', error: 'Vote thành công.'}, status: 200
              # return head 201
            rescue => e
              render json: {message: 'Có lỗi xảy ra.', error: e.message }, status: 400
              return
            end
          else
            $emitter.of('/room').in(@room.id).emit('action full', {id: action_id, price: db_action['price'], voted: redis_action, percent: 100, sender: {}})
            render json: {message: 'Hành động này đã được vote đầy!'}, status: 400
            return
          end
        end
      end
    end



    def doneAction
      return render json: {message: 'Thieu action_id'}, status: 400 if params[:action_id].blank?
      action_id = params[:action_id]
      db_action = fetch_action action_id
      return render json: {message: 'Hành động này không tồn tại!'}, status: 400 if db_action.blank?
      if db_action
        redis_action = $redis.get("actions:#{@room.id}:#{action_id}").to_i
        if db_action['max_vote'] <= redis_action
          $redis.set("actions:#{@room.id}:#{action_id}", 0)
          $emitter.of('/room').in(@room.id).emit('action done', { id: db_action['id'] })
          return json: {message: 'Vote thành công '}, status: 200
        else
          render json: {message: 'Hành động này phải được Vote đầy trước khi được duyệt'}, status: 400
        end
      else
        render json: {message: 'Hành động này không tồn tại!'}, status: 400
      end
    end




    def sendGifts
    	# logger = Logger.new("#{Rails.root}/log/production.log");
      gift_id = params[:gift_id].to_i
      quantity = params[:quantity].to_i
      return render json: {message: 'Không lấy được thông tin user' }, status: 400 if @user.blank?
      return render json: {message: 'Phòng này không tồn tại hoặc đã bị xoá !' }, status: 400 if @room.blank?
      return render json: {message: 'Thieu params gift_id' }, status: 400 if gift_id.blank?
      return render json: {message: 'Thieu params quantity' }, status: 400 if quantity.blank?
      db_gift = fetch_gift gift_id
      return render json: { message: 'Quà tặng không tồn tại!', detail: 'Khong get duoc db_gift by gift_id từ redis or từ database ! ' }, status: 400 if db_gift.blank?
      if db_gift
        if quantity >= 1
          total = db_gift['price'] * quantity
          exp_bct = db_gift['price'] * quantity * 10
          begin
            @user.decreaseMoney(total)
            @user.increaseExp(total)
            @room.broadcaster.increaseExp(exp_bct)
            user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
            vip_data = @token_user['vip'] ? {vip: @token_user['vip']} : 0
            $emitter.of('/room').in(@room.id).emit('gifts recived', { message: 'user gửi quà cho broadcaster' , gift: {id: gift_id, name: db_gift['name'], image: "#{request.base_url}#{db_gift['image']['square']['url']}"}, quantity:quantity, total: total, sender: user, vip: vip_data})
            # insert log
            GiftLogJob.perform_later(@user, @room.id, gift_id, quantity, total)
            UserLogJob.perform_later(@user, @room.id, total)
            return render json: {message: 'send gift thành công ' }, status: 200
          rescue => e
            logger.info("-------------------sendGifts----------------");
            logger.info(e.message);
            return render json: {error: e.message, message: 'Tặng quà không thành công, vui lòng thử lại!'}, status: 400
          end
        else
          return render json: {message: 'Số lượng phải lớn hơn 1'}, status: 400
        end
      else
        return render json: {message: 'Quà tặng này không tồn tại'}, status: 400
      end
    end





    def buyLounge
      cost = params[:cost].to_i
      lounge = params[:lounge].to_i
      if lounge >= 0 && lounge <= 11
        if @user.money >= cost
          if cost > 50
            begin
              current_lounge = $redis.get("lounges:#{@room.id}:#{lounge}")
              if current_lounge.present?
                current_lounge = eval(current_lounge)
                if current_lounge[:cost].to_i >= cost
                  render json: {error: 'Giá mua của bạn phải lớn hơn giá hiện tại'}, status: 400 and return
                end
              end

              exp_bct = cost * 10
              @user.decreaseMoney(cost)
              @user.increaseExp(cost)
              @room.broadcaster.increaseExp(exp_bct)
              user = {
                  id: @user.id,
                  email: @user.email,
                  name: @user.name,
                  username: @user.username,
                  avatar: @user.avatar_path[:avatar],
                  avatar_w60h60: @user.avatar_path[:avatar_w60h60],
                  avatar_w100h100: @user.avatar_path[:avatar_w100h100],
                  avatar_w120h120: @user.avatar_path[:avatar_w120h120],
                  avatar_w200h200: @user.avatar_path[:avatar_w200h200],
                  avatar_w240h240: @user.avatar_path[:avatar_w240h240],
                  avatar_w300h300: @user.avatar_path[:avatar_w300h300],
                  avatar_w400h400: @user.avatar_path[:avatar_w400h400]
                }
              vip_data = @token_user['vip'] ? {vip: @token_user['vip']} : 0
              $redis.set("lounges:#{@room.id}:#{lounge}", {user: user, cost: cost})
              $emitter.of('/room').in(@room.id).emit('buy lounge', { lounge: lounge, user: user, cost: cost, vip: vip_data });

              # insert log
              LoungeLogJob.perform_later(@user, lounge, cost)
              UserLogJob.perform_later(@user, @room.id, cost)

              return head 201
            rescue => e
              render json: {error: e.message}, status: 400
            end
          else
            render json: {error: 'Giá mua phải lớn hơn 50'}, status: 400
          end
        else
          render json: {error: 'Bạn không có đủ tiền'}, status: 400
        end
      else
        render json: {error: 'Ghế này không tồn tại'}, status: 404
      end
    end




    def sendHearts
    	return render json: {message: 'thiếu param hearts'}, status: 400 if params[:hearts].blank?
    	return render json: {message: 'Không lấy được thông tin phòng'}, status: 400 if @room.blank?
    	return render json: {message: 'Không lấy được thông tin của chủ phòng'}, status: 400 if @room.broadcaster.blank?
    	return render json: {message: 'Không lấy được thông tin user'}, status: 400 if @user.blank?
      hearts = params[:hearts].to_i
      @user.with_lock do
        if hearts > 0 && @user.no_heart >= hearts
          begin
            @user.no_heart -= hearts
            if @user.save!
              @user.increaseExp(10)
              @room.broadcaster.recived_heart += hearts
              if @room.broadcaster.save
                @room.broadcaster.increaseExp(hearts)
                user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
                vip = @token_user['vip'] ? {vip: @token_user['vip']} : 0
                $emitter.of('/room').in(@room.id).emit('hearts recived', {message: 'user send heart cho broadcaster', bct_hearts: hearts,user_heart: @user.no_heart, sender: user, vip: vip})
                # insert log
                HeartLogJob.perform_later(@user, @room.id, hearts)
                return render json: {message: 'Gửi tim thành công. Xin cảm ơn bạn.'},status: 200
              else
                render json: {message: 'Trái tim đã được gửi rồi, nhưng broadcaster không nhận được, vui lòng liên hệ người hỗ trợ!'}, status: 400
              	return
              end
            else
              render json: {message: 'Không thể gửi trái tim, Vui lòng thử lại lần nữa', error: @user.errors.full_messages}, status: 400
            	return
            end
          rescue => e
            render json: {message: 'Không thể gửi tim cho chủ phòng. Vui lòng thử lại.', error: e.message}, status: 400
            return
          end
        else
          render json: {message: 'Bạn không có đủ số trái tim'}, status: 400
          return
        end
      end
    end





    def startRoom
      @room.on_air = true
      if @room.save
        _bctTimeLog()
        DeviceNotificationJob.perform_later(@user)
        start_stream @room
        $emitter.of('/room').in(@room.id).emit('room on-air')
        render json: {message: 'Start room thành công'}, status: 200
        return
      else
        render json: {error: 'Phòng này không thể bắt đầu, Vui lòng liên hệ người hỗ trợ'}, status: 400
      end
    end

    def endRoom
      @room.on_air = false
      if @room.present? and @room.save
        _bctTimeLog()
        $emitter.of('/room').in(@room.id).emit('room off')
        end_stream @room
        # remove expired banned user
        banned = $redis.keys("ban:#{@room.id}:*")
        if banned.present?
          banned.each do |key|
            expiry = $redis.get(key)
            $redis.del(key) if Time.now >= Time.at(expiry.to_i) and key
          end
        end
        # remove virtual users in redis
        if $redis.keys("VirtualUsers:#{@room.id}:*").present?
          $redis.del( $redis.keys("VirtualUsers:#{@room.id}:*") )
        end
        render json: {message: 'End room thành công'}, status: 200
        return
      else
        render json: {error: 'Phòng này không thể kết thúc, Vui lòng liên hệ người hỗ trợ'}, status: 400
      end
    end



    def forceEnd
      @room = Room.find(params[:room_id])
      if @room.on_air == false
        return head 200 
      end
      @room.on_air = false
      if @room.present? and @room.save
        _bctTimeLog()
        $emitter.of('/room').in(@room.id).emit('room off')
        end_stream @room

        # remove expired banned user
        banned = $redis.keys("ban:#{@room.id}:*")
        if banned and banned.present?
          banned.each do |key|
            expiry = $redis.get(key)
            $redis.del(key) if Time.now >= Time.at(expiry.to_i)
          end
        end
        # remove virtual users in redis
        if $redis.keys("VirtualUsers:#{@room.id}:*").present?
          $redis.del( $redis.keys("VirtualUsers:#{@room.id}:*") )
        end
        render json: {message: 'Force End room thành công'}, status: 200
        return
      else
        render json: {error: 'Phòng này không thể kết thúc, Vui lòng liên hệ người hỗ trợ'}, status: 400
      end
    end

    def kickUser
      if params[:user_id].present?
        @user = User.find_by_id(params[:user_id])
        if @user.present? and !@user.is_broadcaster
          @user.ban @room.id
          return render json: {message: 'Kick user thanh cong'}, status: 200
          # return head 200
        else
          return render json: {error: 'Kick user không thành công'}, status: 400
          # return head 404
        end
      else
        render json: {error: 'Không đủ tham số'}, status: 400 and return
      end
    end

    private

    def _bctTimeLog
      if @room.on_air
        BctTimeLog.create({:room_id => @room.id, :last_login => @room.broadcaster.user.last_login, :start_room => Time.now, :status => false })
      else
        bct_log = BctTimeLog.where(:room_id => @room.id, :end_room => nil, :flag => false).order("id desc").take
        endRoom = Time.now
        flag = true
        if bct_log.present?
          bct_log.end_room = Time.now
          bct_log.flag = flag
          time_log = Time.now.to_i - bct_log.start_room.to_i
          if time_log >= 1800
            status = true 
          else
            status = false
          end
          bct_log.status = status
          bct_log.save
        end
      end
      return true
    end

    def get_users
      @user_list = $redis.hgetall(@room.id)
      @user_list.each do |key, val|
        @user_list[key] = eval(val)
      end
    end

    def is_subscribed
      if params.has_key?(:room_id)
        @room = Room.find(params[:room_id])
        get_users
        return render json: {message: 'Bạn không đăng kí phòng này'}, status: 400 if(!@user_list.has_key?(@user.email))
        return render json: {message: 'Bạn không được phép vào phòng này'}, status: 400 if @user.is_banned(@room.id)
      else
        return render json: {detail: 'Thiếu tham số room_id', message: 'Phòng này không tồn tại hoặc đã bị xoá!'}, status: 400
      end
    end

    def is_started
        return render json: {message: 'Phòng này chưa bắt đầu hoặc đã tắt.'}, status: 400 if @room.on_air == false
    end

    def check_permission
      if @user.email != @room.broadcaster.user.email
        return render json: {message: 'Bạn không đủ quyền để sử dụng chức năng này'}, status: 400
      end
    end
  end