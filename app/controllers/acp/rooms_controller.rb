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
		screen_text_logs = ScreenTextLog.where(:room_id => @data.id)
		logger.info("---------screen_text_logs:")
		logger.info("#{screen_text_logs.to_json}")
		if screen_text_logs.present?
			screen_text_logs.each do |screen_text_log|
			  screen_text_log.destroy
			end
		end

		
		bct_gifts = BctGift.where(:room_id => @data.id)
		logger.info("---------bct_gifts:")
		logger.info("#{bct_gifts.to_json}")
		if bct_gifts.present?
			bct_gifts.each do |bct_gift|
			  bct_gift.destroy
			end
		end

		bct_actions = BctAction.where(:room_id => @data.id)
		logger.info("---------bct_actions:")
		logger.info("#{bct_actions.to_json}")
		if bct_actions.present?
			bct_actions.each do |bct_action|
			  bct_action.destroy
			end
		end

		action_logs = ActionLog.where(:room_id => @data.id)
		logger.info("---------action_logs:")
		logger.info("#{action_logs.to_json}")
		if action_logs.present?
			action_logs.each do |action_log|
			  action_log.destroy
			end
		end

		user_logs = UserLog.where(:room_id => @data.id)
		logger.info("---------user_logs:")
		logger.info("#{user_logs.to_json}")
		if user_logs.present?
			user_logs.each do |user_log|
			  user_log.destroy
			end
		end

		heart_logs = HeartLog.where(:room_id => @data.id)
		logger.info("---------heart_logs:")
		logger.info("#{heart_logs.to_json}")
		if heart_logs.present?
			heart_logs.each do |heart_log|
			  heart_log.destroy
			end
		end

		gift_logs = GiftLog.where(:room_id => @data.id)
		# logger.info("---------gift_logs:")
		# logger.info("#{gift_logs.to_json}")
		if gift_logs.present?
			gift_logs.each do |gift_log|
			  gift_log.destroy
			end
		end

		fb_share_logs = FbShareLog.where(:room_id => @data.id)
		# logger.info("---------fb_share_logs:")
		# logger.info("#{fb_share_logs.to_json}")
		if fb_share_logs.present?
			fb_share_logs.each do |fb_share_log|
			  fb_share_log.destroy
			end
		end

		bct_time_logs = BctTimeLog.where(:room_id => @data.id)
		# logger.info("---------bct_time_logs:")
		# logger.info("#{bct_time_logs.to_json}")
		if bct_time_logs.present?
			bct_time_logs.each do |bct_time_log|
			  bct_time_log.destroy
			end
		end

		schedules = Schedule.where(:room_id => @data.id)
		if schedules.present?
			schedules.each do |schedule|
			  schedule.destroy
			end
		end
		
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