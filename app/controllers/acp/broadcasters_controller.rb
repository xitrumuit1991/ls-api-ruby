class Acp::BroadcastersController < Acp::ApplicationController
	before_filter :init
	before_action :load_data, only: [:new, :create, :edit, :update]
	before_action :set_data, only: [:show, :basic, :edit, :room, :update, :destroy, :delete_image, :delete_video]

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

	def advanced
		
	end

	def room
		@room = @data.rooms.find_by_is_privated(false)
		@room_types = RoomType.all.order('id desc')
		@room_backgrounds = RoomBackground.all.order('id desc')
	end

	def create
		@data = @model.new(parameters)
		if @data.save
			redirect_to({ action: 'index' }, notice: 'Broadcaster was successfully created.')
		else
			render :new
		end
	end

	def update
		if @data.update(parameters)
			redirect_to({ action: 'index' }, notice: 'Broadcaster was successfully updated.')
		else
			render :edit
		end
	end

	def destroy
		@data.destroy
		redirect_to({ action: 'index' }, notice: 'Broadcaster was successfully destroyed.')
	end

	def delete_image
		if @data.images.present?
      if @data.images.find(params[:id]).destroy
        redirect_to({ action: 'show', id: @data.id }, notice: 'Image was successfully deleted.')
      else
        redirect_to({ action: 'show', id: @data.id }, alert: 'Image not found.')
      end
    else
      redirect_to({ action: 'show', id: @data.id }, alert: 'Image not found.')
    end
	end

	def delete_video
		if @data.videos.present?
      if @data.videos.find(params[:id]).destroy
        redirect_to({ action: 'show', id: @data.id }, notice: 'Video was successfully deleted.')
      else
        redirect_to({ action: 'show', id: @data.id }, alert: 'Video not found.')
      end
    else
      redirect_to({ action: 'show', id: @data.id }, alert: 'Video not found.')
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