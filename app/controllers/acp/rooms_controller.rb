require 'rubygems'
require 'kraken-io'
require 'open-uri'
class Acp::RoomsController < Acp::ApplicationController
	include KrakenHelper
	load_and_authorize_resource
	before_filter :init
  before_action :load_data, only: [:new, :create, :edit, :update]
	before_action :set_data, only: [:show, :edit, :update, :destroy]

	def index
		@data = @model.all.order('id desc')
	end

	def show
	end

	def new
		@data = @model.new
	end

	def edit
	end

	def create
		parameters[:thumb] = parameters[:thumb].nil? ? parameters[:thumb] : optimizeKraken(parameters[:thumb])
		parameters[:thumb_crop] = parameters[:thumb]
		parameters[:thumb_poster] = parameters[:thumb_poster].nil? ? parameters[:thumb_poster] : optimizeKraken(parameters[:thumb_poster])
		@data = @model.new(parameters)
		@data.is_privated = false
		@data.thumb_crop = parameters[:thumb]
		@data.thumb = parameters[:thumb]
		if @data.save
			redirect_to({ action: 'index' }, notice: 'Room was successfully created.')
		else
			render :new
		end
	end

	def update
    prev_path = Rails.application.routes.recognize_path(request.referrer)
		parameters[:thumb] = parameters[:thumb].nil? ? parameters[:thumb] : optimizeKraken(parameters[:thumb])
		parameters[:thumb_crop] = parameters[:thumb]
		parameters[:thumb_poster] = parameters[:thumb_poster].nil? ? parameters[:thumb_poster] : optimizeKraken(parameters[:thumb_poster])
		if @data.update(parameters)
			if prev_path[:controller] == 'acp/rooms'
        redirect_to({ action: 'index' }, notice: "Thông tin phòng '#{@data.title}' được cập nhật thành công.")
      else
        redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: @data.broadcaster.id, id: @data.id }, notice: 'Thông tin phòng được cập nhật thành công.')
      end
		else
			if prev_path[:controller] == 'acp/rooms'
				render :edit
			else
        redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: @data.broadcaster.id, id: @data.id }, alert: @data.errors.full_messages)
			end
		end
	end

	def destroy
		@data.destroy
		redirect_to({ action: 'index' }, notice: 'Room was successfully destroyed.')
	end

	def destroy_m
		@model.destroy(params[:item_id])
		redirect_to({ action: 'index' }, notice: 'Rooms were successfully destroyed.')
	end

	def idol_autocomplete
		@idols = Broadcaster.where("fullname LIKE :query", query: "%#{params[:key]}%")
	end

	def room_autocomplete
		@rooms = Room.where("title LIKE :query", query: "%#{params[:key]}%")
	end

	private
		def init
			@model = controller_name.classify.constantize
		end

		def load_data
			@idols = Broadcaster.all.order('id desc').limit(1)
      @room_types = RoomType.all.order('id desc')
			@room_backgrounds = RoomBackground.all.order('id desc')
    end

		def set_data
			@data = @model.find(params[:id])
		end

		def parameters
			params.require(:room).permit(:thumb, :thumb_crop, :thumb_poster, :broadcaster_id, :title, :slug, :room_type_id)
		end
end