require 'socket.io-emitter'
require "redis"

class Api::V1::LiveController < Api::V1::ApplicationController
	include Api::V1::Authorize

	before_action :authenticate
	before_action :isSubscribed

	def getUserList
		render json: @userlist
	end

	def sendMessage
		message = params[:message]
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room.id).emit('message', message);
		return head 200
	end

	def sendScreenText
		message = params[:message]
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room.id).emit('screen text', message);
		return head 200
	end

	def voteAction
	end

	def buyGift
	end

	def sendHeart
		emitter = SocketIO::Emitter.new
		hearts = Integer(params[:hearts])
		if(hearts > 0 && @user.no_heart >= hearts) then
			@user.no_heart -= hearts
			@room.broadcaster.recived_heart += hearts
			if @user.save then
				if @room.broadcaster.save then
					emitter.of("/room").in(@room.id).emit("hearts recived", {hearts: hearts, sender: @user)
				else
					render json: {error: "Heart already send, but broadcaster can\'t recive, please contact supporter!"}
				end
			else
				render json: {error: "can\'t send heart, please try again later"}
			end
		else
		end
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room.id).emit("room on-air")
	end

	def startRoom
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room.id).emit("room on-air")
	end

	def endRoom
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room.id).emit("room off")
	end

	private
		def getUsers
			redis = Redis.new
			@userlist = redis.hgetall(@room.id)
			@userlist.each do |key, val|
				@userlist[key] = eval(val)
			end
		end

		def isSubscribed
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
end
