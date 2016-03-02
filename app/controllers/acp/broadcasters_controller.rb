class Acp::BroadcastersController < Acp::ApplicationController
	before_filter :init
	before_action :load_data, only: [:new, :create, :edit, :update]
	before_action :set_data, only: [:show, :basic, :edit, :room, :gifts, :images, :videos, :transactions, :update, :destroy, :destroy_gift, :destroy_image, :destroy_video, :ajax_change_background]

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
		if user = User.find(params[:data][:user_id])
			@data = @model.new(parameters)
			@data.user_id = params[:data][:user_id]
			if @data.save
				puts '================'
				puts user.name
				puts '================'
				if user.update(is_broadcaster: true)
					render :new
				else
					redirect_to({ action: 'index' }, notice: 'Idol was successfully updated.')
				end
			else
				render :new
			end
		else
			redirect_to({ action: 'create' }, alert: 'Tài khoản này không tồn tại.')
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

	def ajax_change_background
		data_update = (params[:type] == 'default') ? {broadcaster_background_id: nil, room_background_id: params[:bg_id]} : {broadcaster_background_id: params[:bg_id], room_background_id: nil}
		@data.rooms.find_by_is_privated(false).update(data_update)
		render json: true
	end

	private
		def init
			@model = controller_name.classify.constantize
		end

		def load_data
			@users 			= User.all.order('id desc')
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