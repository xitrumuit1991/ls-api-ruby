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
		emitter.of("/room").in(@room_id).emit('message', message);
		return head 200
	end

	def sendScreenText
		message = params[:message]
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room_id).emit('screen text', message);
		return head 200
	end

	def voteAction
	end

	def buyGift
	end

	def sendHear
	end

	def startRoom
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room_id).emit("room on-air")
	end

	def endRoom
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in(@room_id).emit("room off")
	end

	private
		def getUsers
			redis = Redis.new
			@userlist = redis.hgetall(@room_id)
			@userlist.each do |key, val|
				@userlist[key] = eval(val)
			end
		end

		def isSubscribed
			if(params.has_key?(:room_id)) then
				@room_id = params[:room_id]
				getUsers
				if(!@userlist.has_key?(@user.email)) then
					render json: {error: "You are not subscribe to this room"}, status: 400
				end
			else
				render json: {error: "Missing room_id parameter"}, status: 400
			end
		end
end
