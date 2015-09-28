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
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room.id).emit('message', message);
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
				emitter = SocketIO::Emitter.new
				emitter.of("/room").in(@room.id).emit('screen text', { message: message, sender: user });
				return head 201
			rescue => e
				render json: {error: e.message}, status: 400
			end
		else
			render json: {error: "You don\'t have enough mone"}, status: 403
		end
	end

	def voteAction
		redis = Redis.new
		action_id = params[:action_id]
		dbAction = Action.find(action_id)
		if dbAction
			rAction = redis.get("actions:#{@room.id}:#{action_id}").to_i
			if rAction < dbAction.max_vote
				redis.set("actions:#{@room.id}:#{action_id}", rAction + 1);
				begin
					@user.decreaseMoney(dbAction.price)
					@user.increaseExp(dbAction.price)
					@room.broadcaster.increaseExp(dbAction.price)
					user = {id: @user.id, email: @user.email, name: @user.name, username: @user.username}
					emitter = SocketIO::Emitter.new
					if dbAction.max_vote == rAction + 1
						emitter.of("/room").in(@room.id).emit("action full", {action: action_id, total: dbAction.price, sender: user})
					else
						emitter.of("/room").in(@room.id).emit("action recived", {action: action_id, total: dbAction.price, sender: user})
					end
					return head 201
				rescue => e
					render json: {error: e.message}, status: 400
				end
				return head 201
			else
				render json: {error: "This action has been full"}, status: 403
			end
		else
			render json: {error: "Action doesn\'t exist"}, status: 404
		end
	end

	def getActionStatus
		redis = Redis.new
		keys = redis.keys("actions:#{@room.id}:*")
		result = {}
		keys.each do |key|
			split = key.split(':')
			result[split[2]] = redis.get(key).to_i
		end
		render json: result, status: 200
	end

	def doneAction
		
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
					emitter = SocketIO::Emitter.new
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
	end

	def buyLounge
		redis = Redis.new

	end

	def sendHearts
		emitter = SocketIO::Emitter.new
		hearts = params[:hearts].to_i
		if(hearts > 0 && @user.no_heart >= hearts) then
			@user.no_heart -= hearts
			@room.broadcaster.recived_heart += hearts
			@user.exp += hearts
			@room.broadcaster.exp += hearts
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
		else
			render json: {error: "You don\'t have enough hearts"}, status: 403
		end
	end

	def startRoom
		@room.on_air = true
		if @room.save then
			emitter = SocketIO::Emitter.new
			emitter.of("/room").in(@room.id).emit("room on-air")
			return head 200
		else
			render json: {error: "Can\'t start this room, please contact supporter"}, status: 400
		end
	end

	def endRoom
		@room.on_air = false
		if @room.save then
			emitter = SocketIO::Emitter.new
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
			redis = Redis.new
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
