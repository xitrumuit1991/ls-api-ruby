class Acp::BroadcastersController < Acp::ApplicationController
	before_filter :init
	before_action :load_data, only: [:new, :create, :edit, :update]
	before_action :set_data, only: [:show, :basic, :edit, :room, :gifts, :images, :videos, :transactions, :update, :destroy, :destroy_gift, :destroy_image, :destroy_video]

	def index
		@data = @model.all.order('id desc')
	end

	def show
	end

	def new
		@data = @model.new
		@users = User.all.order('id desc')
	end

	def edit
	end

	def basic
		@user = @data.user
		@levels = UserLevel.all
	end

	def room
		if @room = @data.rooms.find_by_is_privated(false)
			@room_types = RoomType.all.order('id desc')
			@room_backgrounds = RoomBackground.all.order('id desc')
		else
			redirect_to({ action: 'index' }, alert: 'Idol này chưa có phòng.')
		end
	end

	def gifts
		if room = @data.rooms.find_by_is_privated(false)
			@gifts = room.gift_logs.order('id desc')
		else
			redirect_to({ action: 'index' }, alert: 'Idol này chưa có phòng.')
		end
	end

	def images
		@images = @data.images.order('id desc')
	end

	def videos
		@videos = @data.videos.order('id desc')
	end

	def transactions
		@gifts = @data.user.gift_logs.order('id desc')
	end

	def create
		@data = @model.new(parameters)
		@data.user_id = params[:data][:user_id]
		if @data.save
			redirect_to({ action: 'index' }, notice: 'Idol was successfully created.')
		else
			@users = User.all.order('id desc')
			render :new
		end
	end

	def update
		if @data.update(parameters)
			redirect_to({ action: 'index' }, notice: 'Idol was successfully updated.')
		else
			render :edit
		end
	end

	def destroy
		@data.destroy
		redirect_to({ action: 'index' }, notice: 'Idol was successfully destroyed.')
	end

	def destroy_gift
		if @data.rooms.find_by_is_privated(false).gift_logs.present?
      if @data.rooms.find_by_is_privated(false).gift_logs.find(params[:id]).destroy
        redirect_to({ action: 'gifts', broadcaster_id: @data.id }, notice: 'Gift was successfully deleted.')
      else
        redirect_to({ action: 'gifts', broadcaster_id: @data.id }, alert: 'Gift not found.')
      end
    else
      redirect_to({ action: 'gifts', broadcaster_id: @data.id }, alert: 'Gift not found.')
    end
	end

	def destroy_image
		if @data.images.present?
      if @data.images.find(params[:id]).destroy
        redirect_to({ action: 'images', broadcaster_id: @data.id }, notice: 'Image was successfully deleted.')
      else
        redirect_to({ action: 'images', broadcaster_id: @data.id }, alert: 'Image not found.')
      end
    else
      redirect_to({ action: 'images', broadcaster_id: @data.id }, alert: 'Image not found.')
    end
	end

	def destroy_video
		if @data.videos.present?
      if @data.videos.find(params[:id]).destroy
        redirect_to({ action: 'videos', broadcaster_id: @data.id }, notice: 'Video was successfully deleted.')
      else
        redirect_to({ action: 'videos', broadcaster_id: @data.id }, alert: 'Video not found.')
      end
    else
      redirect_to({ action: 'videos', broadcaster_id: @data.id }, alert: 'Video not found.')
    end
	end

	private
		def init
			@model = controller_name.classify.constantize
		end

		def load_data
			@bct_types 	= BctType.all.order('id desc')
			@levels 		= BroadcasterLevel.all
		end

		def set_data
			@data = params[:broadcaster_id].present? ? @model.find(params[:broadcaster_id]) : @model.find(params[:id])
		end
		
		def parameters
			params.require(:data).permit(:fullname, :bct_type_id, :broadcaster_level_id, :broadcaster_exp, :recived_heart, :description)
		end
end