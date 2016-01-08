class Acp::BroadcasterBackgroundsController < Acp::ApplicationController
	before_filter :init
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
			prev_path = Rails.application.routes.recognize_path(request.referrer)
	    if prev_path[:controller] == 'acp/rooms'
	      redirect_to({ controller: 'rooms', action: 'edit', id: params[:room_id] }, notice: "Background được thêm thành công.")
	    else
				redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: @data.broadcaster.id, id: params[:room_id] }, notice: "Background được thêm thành công.")
	    end
		else
			render :new
		end
	end

	def update
		if @data.update(parameters)
			redirect_to({ action: 'index' }, notice: 'Background was successfully updated.')
		else
			render :edit
		end
	end

	def destroy
		@data.destroy
		redirect_to({ action: 'index' }, notice: 'Background was successfully destroyed.')
	end

	private
		def init
			@model = controller_name.classify.constantize
		end

		def set_data
			@data = @model.find(params[:id])
		end

		def parameters
			params.require(:background).permit(:broadcaster_id, :image)
		end
end