class Api::V1::LiveController < Api::V1::ApplicationController
	include Api::V1::Authorize

	before_action :authenticate, except: [:getUserList, :sendMessage]

	def getUserList
		require "redis"
		redis = Redis.new
		list = redis.hgetall("123456789")
		render json: list
	end

	def sendMessage
		require 'socket.io-emitter'
		emitter = SocketIO::Emitter.new
		emitter.of("/room").in("123456789").emit('message', "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages.");
		return head 200
	end
end
