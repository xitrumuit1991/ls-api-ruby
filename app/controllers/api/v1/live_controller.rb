require 'socket.io-emitter'
require "redis"

class Api::V1::LiveController < Api::V1::ApplicationController
	include Api::V1::Authorize

	before_action :authenticate
	before_action :checkSubscribed
	before_action :checkStarted, only: [:voteAction, :getActionStatus, :sendScreenText, :buyGift, :getLoungeStatus]
	before_action :checkPermission, only: [:startRoom, :endRoom]

	def getUserList
		render json: @userlist
	end

	def sendMessage
		message = params[:message]
		emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
		user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
		emitter.of("/room").in(@room.id).emit('message', {message: message, sender: user});
		return head 201
	end

	def sendScreenText
		cost = 1
		message = params[:message]
		if @user.money >= cost then
			begin
				@user.decreaseMoney(cost)
				@user.increaseExp(cost)
				@room.broadcaster.increaseExp(cost)
				user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
				emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
				emitter.of("/room").in(@room.id).emit('screen text', { message: message, sender: user });
				return head 201
			rescue => e
				render json: {error: e.message}, status: 400
			end
		else
			render json: {error: "You don\'t have enough money"}, status: 403
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
				begin
					@user.decreaseMoney(dbAction.price)
					@user.increaseExp(dbAction.price)
					@room.broadcaster.increaseExp(dbAction.price)
					user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
					emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
					if dbAction.max_vote == new_value
						emitter.of("/room").in(@room.id).emit("action full", {action: action_id, price: dbAction.price, voted: new_value, percent: percent, sender: user})
					else
						emitter.of("/room").in(@room.id).emit("action recived", {action: action_id, price: dbAction.price, voted: new_value, percent: percent, sender: user})
					end
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

	def getActionStatus
		redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
		keys = redis.keys("actions:#{@room.id}:*")
		status = {}
		keys.each do |key|
			split = key.split(':')
			status[split[2].to_i] = redis.get(key).to_i
		end
		emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
		emitter.of("/room").in(@room.id).emit("action status", { status: status })
		return head 200
	end

	def doneAction
		redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
		action_id = params[:action_id]
		dbAction = RoomAction.find(action_id)
		if dbAction
			keys = redis.keys("actions:#{@room.id}:*")
			keys.each do |key|
				split = key.split(':')
				point = redis.get(key).to_i
				if action_id == split[2].to_i && point == dbAction.max_vote
					redis.del(key)
					emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))_value
					emitter.of("/room").in(@room.id).emit("action done", { action: action_id })
				end
			end
			return head 200
		else
			render json: {error: "Action doesn\'t exist"}, status: 404
		end
	end

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
					emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
					emitter.of("/room").in(@room.id).emit("gifts recived", {gift: gift_id, quantity:quantity, total: total, sender: user})
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

	def getLoungeStatus
		redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
		keys = redis.keys("lounges:#{@room.id}:*")
		status = {}
		keys.each do |key|
			split = key.split(':')
			status[split[2]] = eval(redis.get(key))
		end
		emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
		emitter.of("/room").in(@room.id).emit("lounge status", { status: status })
		return head 200
	end

	def buyLounge
		redis = Redis.new(:host => Settings.redis_host, :port => Settings.redis_port)
		cost = params[:cost].to_i
		lounge = params[:lounge].to_i
		if lounge > 0 && lounge <= 12
			if @user.money >= cost then
				begin
					if current_lounge = redis.get("lounges:#{@room.id}:#{lounge}")
						current_lounge = eval(current_lounge)
						if current_lounge[:cost].to_i >= cost
							render json: {error: "You don\'t have enough money to buy this lounge"}, status: 403 and return
						end
					end
					@user.decreaseMoney(cost)
					@user.increaseExp(cost)
					@room.broadcaster.increaseExp(cost)
					user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
					lounge_info = {user: user, cost: cost}
					redis.set("lounges:#{@room.id}:#{lounge}", lounge_info.to_json);
					emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
					emitter.of("/room").in(@room.id).emit('buy lounge', { num: lounge, lounge: lounge_info });
					return head 201
				rescue => e
					render json: {error: e.message}, status: 400
				end
			else
				render json: {error: "You don\'t have enough money"}, status: 403
			end
		else
			render json: {error: "This lounge doesn\'t exist"}, status: 400
		end
	end

	def sendHearts
		emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
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

	def startRoom
		@room.on_air = true
		if @room.save then
			emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
			emitter.of("/room").in(@room.id).emit("room on-air")
			return head 200
		else
			render json: {error: "Can\'t start this room, please contact supporter"}, status: 400
		end
	end

	def endRoom
		@room.on_air = false
		if @room.save then
			emitter = SocketIO::Emitter.new(Redis.new(:host => Settings.redis_host, :port => Settings.redis_port))
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
					render json: {error: "You are not subscribe to this room"}, status: 403
				end
			else
				render json: {error: "Missing room_id parameter"}, status: 404
			end
		end

		def checkStarted
			if !@room.on_air then
				render json: {error: "This room is off"}, status: 403
			end
		end

		def checkPermission
			if @user.email != @room.broadcaster.user.email then
				render json: {error: "You don\'t has permission to access this function"}, status: 403
			end
		end

end
