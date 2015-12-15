class Acp::RoomTypesController < Acp::ApplicationController

	before_action :set_room_type, only: [:show, :edit, :update, :destroy]

	def index
		@data = RoomType.all.order('id desc')
	end

	def show
	end

	def new
		@room_type = RoomType.new
	end

	def edit
	end

	def create
		@room_type = RoomType.new(room_type_params)
		if @room_type.save
			redirect_to acp_room_types_path, notice: 'Room type was successfully created.'
		else
			render :new
		end
	end

	def update
		if @room_type.update(room_type_params)
			redirect_to  acp_room_types_path, notice: 'Room type was successfully updated.'
		else
			render :edit
		end
	end

	def destroy
		@room_type.destroy
		redirect_to acp_room_types_path, notice: 'Room type was successfully destroyed.'
	end

	private
		def set_room_type
			@room_type = RoomType.find(params[:id])
		end
		def room_type_params
			params.require(:room_type).permit(:title, :slug, :description)
		end
end