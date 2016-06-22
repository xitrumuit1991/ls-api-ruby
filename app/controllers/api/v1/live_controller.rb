class Api::V1::LiveController < Api::V1::ApplicationController
  include Api::V1::Authorize
  include Api::V1::CacheHelper

  before_action :authenticate, :checkSubscribed
  before_action :checkStarted, except: [:sendMessage, :startRoom, :getUserList, :kickUser]
  before_action :checkPermission, only: [:startRoom, :endRoom, :doneAction, :kickUser]

  def getUserList
    render json: @userlist
  end

  def addHeartInRoom
    maxHeart  = @user.user_level.heart_per_day
    userHeart = UserReceivedHeart.find_by_user_id(@user.id)
    # hearts    = params[:hearts].to_i
    if !userHeart
      userHeart = UserReceivedHeart.create(:user_id => @user.id,:hearts => 1)
    end
    if (DateTime.now.to_i - userHeart.updated_at.to_i) >= Settings.timeAddHeart
      if @user.no_heart < maxHeart
        begin
          userHeart.update(:hearts => userHeart.hearts.to_i + 1)
          @user.update(:no_heart => @user.no_heart.to_i + 1)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          $emitter.of("/room").in(@room.id).emit("add hearts", {hearts: @user.no_heart, sender: user})
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
    message = params[:message]
    room_id = params[:room_id]
    vip_weight = @token_user["vip"]
    vip = fetch_vip vip_weight
    no_char = vip ? vip["no_char"].to_i : 40

    if message.length > 0
      if message.length <= no_char
        user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
        vip_data = vip_weight ? {vip: vip_weight} : 0
        $emitter.of("/room").in(room_id).emit('message', {message: message, sender: user, vip: vip_data});

        return head 201
      else
        render json: {error: "Nội dung chat không được vượt quá #{no_char} kí tự !"}, status: 400
      end
    else
      render json: {error: "Vui lòng nhập nội dung chat trước khi gởi !"}, status: 400
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
        $emitter.of("/room").in(@room.id).emit('screen text', { message: message, sender: user });

        # insert log
        @user.screen_text_logs.create(room_id: @room.id, content: message, cost: cost)
        UserLogJob.perform_later(@user, @room.id, cost)

        return head 201
      rescue => e
        render json: {error: e.message}, status: 400
      end
    else
      render json: {error: "Bạn không có đủ tiền"}, status: 403
    end
  end

  def voteAction
    action_id = params[:action_id]
    dbAction = fetch_action action_id
    if dbAction
      rAction = $redis.get("actions:#{@room.id}:#{action_id}").to_i
      if rAction < dbAction["max_vote"]
        begin
          @user.decreaseMoney(dbAction["price"])
          new_value = rAction + 1
          percent = new_value * 100 / dbAction["max_vote"]
          $redis.incr("actions:#{@room.id}:#{action_id}")
          
          @user.increaseExp(dbAction["price"])
          @room.broadcaster.increaseExp(dbAction["price"] * 10)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          if dbAction["max_vote"] == new_value
            $emitter.of("/room").in(@room.id).emit("action full", {id: action_id, price: dbAction["price"], voted: new_value, percent: percent, sender: user})
          else
            $emitter.of("/room").in(@room.id).emit("action recived", {id: action_id, price: dbAction["price"], voted: new_value, percent: percent, sender: user})
          end

          # insert log
          ActionLogJob.perform_later(@user, @room.id, action_id, dbAction["price"])
          UserLogJob.perform_later(@user, @room.id, dbAction["price"])

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
    action_id = params[:action_id]
    dbAction = fetch_action action_id
    if dbAction
      rAction = $redis.get("actions:#{@room.id}:#{action_id}").to_i
      if dbAction["max_vote"] <= rAction
        $redis.set("actions:#{@room.id}:#{action_id}", 0)
        $emitter.of("/room").in(@room.id).emit("action done", { id: dbAction["id"] })
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
    dbGift = fetch_gift gift_id
    if dbGift
      if quantity >= 1
        total = dbGift["price"] * quantity
        expBct = dbGift["price"] * quantity * 10
        begin
          @user.decreaseMoney(total)
          @user.increaseExp(total)
          @room.broadcaster.increaseExp(expBct)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          vip_data = @token_user["vip"] ? {vip: @token_user["vip"]} : 0
          $emitter.of("/room").in(@room.id).emit("gifts recived", {gift: {id: gift_id, name: dbGift["name"], image: "#{request.base_url}#{dbGift['image']['square']['url']}"}, quantity:quantity, total: total, sender: user, vip: vip_data})

          # insert log
          GiftLogJob.perform_later(@user, @room.id, gift_id, quantity, total)
          UserLogJob.perform_later(@user, @room.id, total)

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
    cost = params[:cost].to_i
    lounge = params[:lounge].to_i
    if lounge >= 0 && lounge <= 11
      if @user.money >= cost then
        if cost > 50
          begin
            if current_lounge = $redis.get("lounges:#{@room.id}:#{lounge}")
              current_lounge = eval(current_lounge)
              if current_lounge[:cost].to_i >= cost
                render json: {error: "Giá mua của bạn phải lớn hơn giá hiện tại"}, status: 400 and return
              end
            end

            expBct = cost * 10
            @user.decreaseMoney(cost)
            @user.increaseExp(cost)
            @room.broadcaster.increaseExp(expBct)
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
            vip_data = @token_user["vip"] ? {vip: @token_user["vip"]} : 0
            $redis.set("lounges:#{@room.id}:#{lounge}", {user: user, cost: cost});
            $emitter.of("/room").in(@room.id).emit('buy lounge', { lounge: lounge, user: user, cost: cost, vip: vip_data });

            # insert log
            LoungeLogJob.perform_later(@user, lounge, cost)
            UserLogJob.perform_later(@user, @room.id, cost)

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
    hearts = params[:hearts].to_i
    @user.lock!
    if(hearts > 0 && @user.no_heart >= hearts) then
      begin
        @user.no_heart -= hearts
        if @user.save!
          @user.increaseExp(10)
          @room.broadcaster.lock!
          @room.broadcaster.recived_heart += hearts
          if @room.broadcaster.save!
            @room.broadcaster.increaseExp(hearts)
            user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
            vip = @token_user["vip"] ? {vip: @token_user["vip"]} : 0
            $emitter.of("/room").in(@room.id).emit("hearts recived", {bct_hearts: hearts,user_heart: @user.no_heart, sender: user, vip: vip})

            # insert log
            HeartLogJob.perform_later(@user, @room.id, hearts)

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
      $emitter.of("/room").in(@room.id).emit("room on-air")
      return head 200
    else
      render json: {error: "Phòng này không thể bắt đầu, Vui lòng liên hệ người hỗ trợ"}, status: 400
    end
  end

  def endRoom
    @room.on_air = false
    if @room.save then
      $emitter.of("/room").in(@room.id).emit("room off")
      return head 200
    else
      render json: {error: "Phòng này không thể kết thúc, Vui lòng liên hệ người hỗ trợ"}, status: 400
    end
  end

  def kickUser
    if params[:user_id].present?
      days = params[:days].present? ? params[:days].to_i : 1
      note = params[:note].present? ? params[:note] : ''
      @ban_user = User.find_by_id(params[:user_id])
      if @ban_user.present?
        @ban_user.ban @room.id, days, note
        return head 200
      else
        return head 404
      end
    else
      render json: {error: 'Không đủ tham số'}, status: 400 and return
    end
  end

  private

  def getUsers
    @userlist = $redis.hgetall(@room.id)
    @userlist.each do |key, val|
      @userlist[key] = eval(val)
    end
  end

  def checkSubscribed
    if(params.has_key?(:room_id)) then
      @room = Room.find(params[:room_id])
      getUsers
      render json: {error: "Bạn không đăng kí phòng này"}, status: 403 and return if(!@userlist.has_key?(@user.email))
      render json: {error: "Bạn không được phép vào phòng này"}, status: 403 and return if @user.is_banned(@room.id)
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