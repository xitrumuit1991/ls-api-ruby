require 'socket.io-emitter'
require "redis"

class Api::V1::LiveController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate, :checkSubscribed
  before_action :checkStarted, except: [:sendMessage, :startRoom, :getUserList]
  before_action :checkPermission, only: [:startRoom, :endRoom, :doneAction]

  def getUserList
    render json: @userlist
  end

  def addHeartInRoom
    maxHeart  = @user.user_level.heart_per_day
    userHeart = UserReceivedHeart.find_by_user_id(@user.id)
    hearts    = params[:hearts].to_i
    if !userHeart
      userHeart = UserReceivedHeart.create(:user_id => @user.id,:hearts => 1)
    end
    if (DateTime.now.to_i - userHeart.updated_at.to_i) >= Settings.timeAddHeart
      if @user.no_heart < maxHeart
        begin
          userHeart.update(:hearts => userHeart.hearts.to_i + 1)
          @user.update(:no_heart => @user.no_heart.to_i + 1)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
          emitter.of("/room").in(@room.id).emit("add hearts", {hearts: @user.no_heart, sender: user})
          return head 201
        rescue => e
          render json: {error: e.message}, status: 400
        end
      else
        return head 204
      end
    else
      return head 204
    end
  end

  def sendMessage
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    message = params[:message]
    room_id = params[:room_id]

    vipPackage = @user.user_has_vip_packages.find_by_actived(true)
    no_char = vipPackage.present? ? vipPackage.vip_package.vip.no_char : 40
    last_message = redis.get("last_message:#{room_id}:#{@user.id}")
    timeLastMsg = !last_message.blank? ? last_message : 0
    duration = params[:timestamp].to_i - timeLastMsg.to_i

    if @user.is_broadcaster && @user.public_room.id == room_id.to_i
      timeChat = 0
    elsif vipPackage.present?
      timeChat = vipPackage.vip_package.vip.screen_text_time
    else
      timeChat = 200
    end
    timeChat = 0
    @user.increaseExp(1)
    if message.length > 0
      if message.length <= no_char
        if duration >= timeChat
          redis.set("last_message:#{room_id}:#{@user.id}", params[:timestamp]);
          emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          emitter.of("/room").in(room_id).emit('message', {message: message, sender: user});

          return head 201
        else
          render json:{message: "Vui lòng gửi tin nhắn sau #{timeChat - duration} s!"}, status: 200
        end
      else
        render json:{error: "Nội dung chat không được vượt quá #{no_char} kí tự !"}, status: 400
      end
    else
      render json:{error: "Vui lòng nhập nội dung chat trước khi gởi !"}, status: 400
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
        user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
        emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
        emitter.of("/room").in(@room.id).emit('screen text', { message: message, sender: user });

        # insert log
        @user.screen_text_logs.create(room_id: @room.id, content: message, cost: cost)
        @user.user_logs.create(room_id: @room.id, money: cost)

        return head 201
      rescue => e
        render json: {error: e.message}, status: 400
      end
    else
      render json: {error: "Bạn không có đủ tiền"}, status: 403
    end
  end

  def voteAction
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    action_id = params[:action_id]
    dbAction = RoomAction.find(action_id)
    if dbAction
      rAction = redis.get("actions:#{@room.id}:#{action_id}").to_i
      if rAction < dbAction.max_vote
        new_value = rAction + 1
        percent = new_value * 100 / dbAction.max_vote
        redis.set("actions:#{@room.id}:#{action_id}", new_value);
        expUser = formulaExpForUser(dbAction.price, 1)
        expBct = formulaExpForBct(dbAction.price, 1)
        begin
          @user.decreaseMoney(dbAction.price)
          @user.increaseExp(expUser)
          @room.broadcaster.increaseExp(expBct)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
          if dbAction.max_vote == new_value
            emitter.of("/room").in(@room.id).emit("action full", {id: action_id, price: dbAction.price, voted: new_value, percent: percent, sender: user})
          else
            emitter.of("/room").in(@room.id).emit("action recived", {id: action_id, price: dbAction.price, voted: new_value, percent: percent, sender: user})
          end

          # insert log
          @user.action_logs.create(room_id: @room.id, room_action_id: action_id, cost: dbAction.price)
          @user.user_logs.create(room_id: @room.id, money: dbAction.price)

          return head 201
        rescue => e
          render json: {error: e.message}, status: 400
        end
      else
        render json: {error: "This action has been full"}, status: 403
      end
    else
      render json: {error: "Action doesn\'t exist"}, status: 404
    end
  end

  def doneAction
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    action_id = params[:action_id]
    dbAction = RoomAction.find(action_id)
    if dbAction
      rAction = redis.get("actions:#{@room.id}:#{action_id}").to_i
      if dbAction.max_vote <= rAction
        redis.set("actions:#{@room.id}:#{action_id}", 0)
        emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
        emitter.of("/room").in(@room.id).emit("action done", { id: dbAction.id, image: dbAction.image.square })
        return head 200
      else
        render json: {error: "Hành động này phải được Vote trước khi được duyệt"}, status: 400
      end
    else
      render json: {error: "Hành động này không tồn tại"}, status: 404
    end
  end

  def sendGifts
    gift_id = params[:gift_id].to_i
    quantity = params[:quantity].to_i
    dbGift = Gift.find(gift_id)
    if dbGift then
      if quantity >= 1 then
        expUser = formulaExpForUser(dbGift.price, quantity)
        if UserLog.where("user_id = ? AND created_at > ? AND created_at < ?", @user.id, Time.now.beginning_of_day, Time.now).count == 0
          expUser += 10
        end
        total = dbGift.price * quantity
        expBct = formulaExpForBct(dbGift.price, quantity)
        begin
          @user.decreaseMoney(total)
          @user.increaseExp(expUser)
          @room.broadcaster.increaseExp(expBct)

          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
          emitter.of("/room").in(@room.id).emit("gifts recived", {gift: {id: gift_id, name: dbGift.name, image: dbGift.image_url}, quantity:quantity, total: total, sender: user})

          # insert log
          @user.gift_logs.create(room_id: @room.id, gift_id: gift_id, quantity: quantity, cost: total)
          @user.user_logs.create(room_id: @room.id, money: total)

          return head 201
        rescue => e
          render json: {error: e.message}, status: 400
        end
      else
        render json: {error: "Số lượng phải lớn hơn 1"}, status: 400
      end
    else
      render json: {error: 'Quà tặng này không tồn tại'}, status: 404
    end
  end

  def buyLounge
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    cost = params[:cost].to_i
    lounge = params[:lounge].to_i
    if lounge >= 0 && lounge <= 11
      if @user.money >= cost then
        if cost > 50
          begin
            if current_lounge = redis.get("lounges:#{@room.id}:#{lounge}")
              current_lounge = eval(current_lounge)
              if current_lounge[:cost].to_i >= cost
                render json: {error: "Giá mua của bạn phải lớn hơn giá hiện tại"}, status: 400 and return
              end
            end
            expUser = formulaExpForUser(cost, 1)
            if UserLog.where("user_id = ? AND created_at > ? AND created_at < ?", @user.id, Time.now.beginning_of_day, Time.now).count == 0
              expUser += 10
            end
            expBct = formulaExpForBct(cost, 1)
            @user.decreaseMoney(cost)
            @user.increaseExp(expUser)
            @room.broadcaster.increaseExp(expBct)
            user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
            redis.set("lounges:#{@room.id}:#{lounge}", {user: user, cost: cost});
            emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
            emitter.of("/room").in(@room.id).emit('buy lounge', { lounge: lounge, user: user, cost: cost });

            # insert log
            @user.lounge_logs.create(room_id: @room.id, lounge: lounge, cost: cost)
            @user.user_logs.create(room_id: @room.id, money: cost)

            return head 201
          rescue => e
            render json: {error: e.message}, status: 400
          end
        else
          render json: {error: "Giá mua phải lớn hơn 50"}, status: 400
        end
      else
        render json: {error: "Bạn không có đủ tiền"}, status: 400
      end
    else
      render json: {error: "Ghế này không tồn tại"}, status: 404
    end
  end

  def sendHearts
    emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
    hearts = params[:hearts].to_i
    if(hearts > 0 && @user.no_heart >= hearts) then
      begin
        @user.no_heart -= hearts
        @room.broadcaster.recived_heart += hearts
        @user.increaseExp(10)
        @room.broadcaster.increaseExp(hearts)
        if @user.save then
          if @room.broadcaster.save then
            user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
            emitter.of("/room").in(@room.id).emit("hearts recived", {bct_hearts: hearts,user_heart: @user.no_heart, sender: user})

            # insert log
            @user.heart_logs.create(room_id: @room.id, quantity: hearts)

            return head 201
          else
            render json: {error: "Trái tim đã được gửi rồi, nhưng broadcaster không nhận được, vui lòng liên hệ người hỗ trợ!"}, status: 400
          end
        else
          render json: {error: "Không thể gửi trái tim, Vui lòng thử lại lần nữa"}, status: 400
        end
      rescue => e
        render json: {error: e.message}, status: 400
      end
    else
      render json: {error: "Bạn không có đủ số trái tim"}, status: 403
    end
  end

  def startRoom
    @room.on_air = true
    if @room.save then
      emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
      emitter.of("/room").in(@room.id).emit("room on-air")
      return head 200
    else
      render json: {error: "Phòng này không thể bắt đầu, Vui lòng liên hệ người hỗ trợ"}, status: 400
    end
  end

  def endRoom
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    @room.on_air = false
    if @room.save then
      # Delete actions and lounges
      rActions = redis.keys("actions:#{@room.id}:*")
      # rLounges = redis.keys("lounges:#{@room.id}:*")
      redis.del rActions if !rActions.empty?
      # redis.del rLounges if !rLounges.empty?

      # Broadcast to room
      emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
      emitter.of("/room").in(@room.id).emit("room off")
      return head 200
    else
      render json: {error: "Phòng này không thể kết thúc, Vui lòng liên hệ người hỗ trợ"}, status: 400
    end
  end

  def kickUser
  end

  private
  def formulaExpForUser(price, quantity)
    vip = UserHasVipPackage::find_by_user_id(@user.id)
    if vip
      exp = price * quantity * vip.vip_package.vip.exp_bonus
      return exp
    else
      exp = price * quantity * 1
      return exp
    end
  end

  def formulaExpForBct(price, quantity)
    return price * quantity * 10
  end

  def getUsers
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    @userlist = redis.hgetall(@room.id)
    @userlist.each do |key, val|
      @userlist[key] = eval(val)
    end
  end

  def checkSubscribed
    if(params.has_key?(:room_id)) then
      @room = Room.find(params[:room_id])
      getUsers
      if(!@userlist.has_key?(@user.email)) then
        render json: {error: "Bạn không đăng kí phòng này"}, status: 403 and return
      end
    else
      render json: {error: "Thiếu tham số room_id "}, status: 404 and return
    end
  end

  def checkStarted
    if !@room.on_air then
      render json: {error: "Phòng này đã tắt"}, status: 403  and return
    end
  end

  def checkPermission
    if @user.email != @room.broadcaster.user.email then
      render json: {error: "Bạn không đủ quyền để sử dụng chức năng này"}, status: 403 and return
    end
  end

end