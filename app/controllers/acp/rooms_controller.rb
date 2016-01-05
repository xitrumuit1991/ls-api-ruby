class Acp::RoomsController < Acp::ApplicationController
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
		@data = @model.new(parameters)
		if @data.save
			redirect_to({ action: 'index' }, notice: 'Room was successfully created.')
		else
			render :new
		end
	end

	def update
		if @data.update(parameters)
			redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: @data.broadcaster.id, id: @data.id }, notice: 'Room was successfully updated.')
		else
			render :edit
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

	private
		def init
			@model = controller_name.classify.constantize
		end

		def load_data
			@idols = Broadcaster.all.order('id desc')
      @room_types = RoomType.all.order('id desc')
			@room_backgrounds = RoomBackground.all.order('id desc')
    end

		def set_data
			@data = @model.find(params[:id])
		end

		def parameters
			params.require(:room).permit(:thumb, :title, :room_type_id)
		end
end