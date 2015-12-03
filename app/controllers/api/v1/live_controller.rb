require 'socket.io-emitter'
require "redis"

class Api::V1::LiveController < Api::V1::ApplicationController
  include Api::V1::Authorize

  before_action :authenticate
  before_action :checkSubscribed
  before_action :checkStarted, only: [:voteAction, :getActionStatus, :sendScreenText, :sendGifts, :buyLounge, :endRoom, :doneAction, :sendHearts]
  before_action :checkPermission, only: [:startRoom, :endRoom, :doneAction]

  resource_description do
    short 'Live function'
    param :room_id, :number, :desc => "Room's id", :required => true
    error :code => 401, :desc => "Unauthorized"
    error :code => 404, :desc => "Room not found"
    formats ['json']
  end

  def getUserList
    render json: @userlist 
  end

  api! "send normal message"
  param :message, String, :required => true
  error :code => 403, :desc => "Maybe you miss subscribe room or room not started"
  def sendMessage
    message = params[:message]
    emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
    user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
    emitter.of("/room").in(@room.id).emit('message', {message: message, sender: user});
    return head 201
  end

  api! "send screentext message"
  param :message, String, :required => true
  error :code => 403, :desc => "Maybe you miss subscribe room or room not started"
  def sendScreenText
    cost = 1
    message = params[:message]

    if @user.money >= cost then
      begin
        @user.decreaseMoney(cost)
        @user.increaseExp(cost)
        @room.broadcaster.increaseExp(cost)
        user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
        emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
        emitter.of("/room").in(@room.id).emit('screen text', { message: message, sender: user });

        # insert log
        @user.screen_text_logs.create(room_id: @room.id, content: message, cost: cost)

        return head 201
      rescue => e
        render json: {error: e.message}, status: 400
      end
    else
      render json: {error: "You don\'t have enough money"}, status: 403
    end
  end

  api! "vote action"
  param :action_id, :number, :desc => "Action's id", :required => true
  error :code => 403, :desc => "Maybe you miss subscribe room or room not started or action has been full"
  error :code => 404, :desc => "action not found"
  error :code => 400, :desc => "Bad request"
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
        begin
          @user.decreaseMoney(dbAction.price)
          @user.increaseExp(dbAction.price)
          @room.broadcaster.increaseExp(dbAction.price)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
          if dbAction.max_vote == new_value
            emitter.of("/room").in(@room.id).emit("action full", {id: action_id, price: dbAction.price, voted: new_value, percent: percent, sender: user})
          else
            emitter.of("/room").in(@room.id).emit("action recived", {id: action_id, price: dbAction.price, voted: new_value, percent: percent, sender: user})
          end

          # insert log
          @user.action_logs.create(room_id: @room.id, room_action_id: action_id, cost: dbAction.price)

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

  api! "done action"
  description "make action done, for room's broadcaster only"
  param :action_id, :number, :desc => "Action's id", :required => true
  error :code => 403, :desc => "Maybe you miss subscribe room or room not started or you is'nt broadcaster"
  error :code => 404, :desc => "action not found"
  error :code => 400, :desc => "action not full"
  def doneAction
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    action_id = params[:action_id]
    dbAction = RoomAction.find(action_id)
    if dbAction
      rAction = redis.get("actions:#{@room.id}:#{action_id}").to_i
      if dbAction.max_vote <= rAction
        redis.set("actions:#{@room.id}:#{action_id}", 0)
        emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
        emitter.of("/room").in(@room.id).emit("action done", { id: action_id })
        return head 200
      else
        render json: {error: "This action must be full before set to done"}, status: 400
      end
    else
      render json: {error: "Action doesn\'t exist"}, status: 404
    end
  end

  api! "send gifts"
  param :gift_id, :number, :desc => "gift's id", :required => true
  param :quantity, :number, :required => true
  error :code => 403, :desc => "Maybe you miss subscribe room or room not started"
  error :code => 404, :desc => "gift not found"
  error :code => 400, :desc => "Bad request"
  def sendGifts
    gift_id = params[:gift_id].to_i
    quantity = params[:quantity].to_i
    dbGift = Gift.find(gift_id)
    if dbGift then
      if quantity >= 1 then
        total = dbGift.price * quantity
        begin
          @user.decreaseMoney(total)
          @user.increaseExp(total)
          @room.broadcaster.increaseExp(total)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
          emitter.of("/room").in(@room.id).emit("gifts recived", {gift: {id: gift_id, name: dbGift.name, image: dbGift.image_url}, quantity:quantity, total: total, sender: user})

          # insert log
          @user.gift_logs.create(room_id: @room.id, gift_id: gift_id, quantity: quantity, cost: total)

          return head 201
        rescue => e
          render json: {error: e.message}, status: 400
        end
      else
        render json: {error: "Quantity must larger than 1"}, status: 400
      end
    else
      return head 404
    end
  end

  api! "buy VIP lounge"
  param :lounge, :number, :desc => "Longe index", :required => true
  param :cost, :number, :desc => "cost to buy lounge", :required => true
  error :code => 403, :desc => "Maybe you miss subscribe room or room not started or dont have enough money"
  error :code => 404, :desc => "Invalid lounge index"
  error :code => 400, :desc => "Bad request"
  def buyLounge
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    cost = params[:cost].to_i
    lounge = params[:lounge].to_i
    if lounge >= 0 && lounge <= 11
      if @user.money >= cost then
        begin
          if current_lounge = redis.get("lounges:#{@room.id}:#{lounge}")
            current_lounge = eval(current_lounge)
            if current_lounge[:cost].to_i >= cost
              render json: {error: "Your bit must larger than curent cost"}, status: 403 and return
            end
          end
          @user.decreaseMoney(cost)
          @user.increaseExp(cost)
          @room.broadcaster.increaseExp(cost)
          user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
          redis.set("lounges:#{@room.id}:#{lounge}", {user: user, cost: cost});
          emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
          emitter.of("/room").in(@room.id).emit('buy lounge', { lounge: lounge, user: user, cost: cost });

          # insert log
          @user.lounge_logs.create(room_id: @room.id, lounge: lounge, cost: cost)

          return head 201
        rescue => e
          render json: {error: e.message}, status: 400
        end
      else
        render json: {error: "You don\'t have enough money"}, status: 403
      end
    else
      render json: {error: "This lounge doesn\'t exist"}, status: 404
    end
  end

  api! "send heart"
  param :hearts, :number, :desc => "number of heart", :required => true
  error :code => 403, :desc => "Maybe you miss subscribe room or room not started or dont have enough heart"
  error :code => 400, :desc => "Bad request"
  def sendHearts
    emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
    hearts = params[:hearts].to_i
    if(hearts > 0 && @user.no_heart >= hearts) then
      begin
        @user.no_heart -= hearts
        @room.broadcaster.recived_heart += hearts
        @user.increaseExp(hearts)
        @room.broadcaster.increaseExp(hearts)
        if @user.save then
          if @room.broadcaster.save then
            user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
            emitter.of("/room").in(@room.id).emit("hearts recived", {hearts: hearts, sender: user})

            # insert log
            @user.heart_logs.create(room_id: @room.id, quantity: hearts)

            return head 201
          else
            render json: {error: "Heart already send, but broadcaster can\'t recive, please contact supporter!"}, status: 400
          end
        else
          render json: {error: "can\'t send heart, please try again later"}, status: 400
        end
      rescue => e
        render json: {error: e.message}, status: 400
      end
    else
      render json: {error: "You don\'t have enough hearts"}, status: 403
    end
  end

  api! "start room"
  description "for broadcaster only"
  def startRoom
    @room.on_air = true
    if @room.save then
      emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
      emitter.of("/room").in(@room.id).emit("room on-air")
      return head 200
    else
      render json: {error: "Can\'t start this room, please contact supporter"}, status: 400
    end
  end

  api! "end room"
  description "for broadcaster only"
  def endRoom
    redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
    @room.on_air = false
    if @room.save then
      # Delete actions and lounges
      rActions = redis.keys("actions:#{@room.id}:*")
      rLounges = redis.keys("lounges:#{@room.id}:*")
      redis.del rActions if !rActions.empty?
      redis.del rLounges if !rLounges.empty?

      # Broadcast to room
      emitter = SocketIO::Emitter.new({redis: Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)})
      emitter.of("/room").in(@room.id).emit("room off")
      return head 200
    else
      render json: {error: "Can\'t start this room, please contact supporter"}, status: 400
    end
  end

  def kickUser
  end

  private
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
          render json: {error: "You are not subscribe to this room"}, status: 403 and return
        end
      else
        render json: {error: "Missing room_id parameter"}, status: 404 and return
      end
    end

    def checkStarted
      if !@room.on_air then
        render json: {error: "This room is off"}, status: 403  and return
      end
    end

    def checkPermission
      if @user.email != @room.broadcaster.user.email then
        render json: {error: "You don\'t has permission to access this function"}, status: 403 and return
      end
    end

end