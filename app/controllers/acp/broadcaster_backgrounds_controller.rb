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
		prev_path = Rails.application.routes.recognize_path(request.referrer)
		@data = @model.new(parameters)
		if @data.save
	    if prev_path[:controller] == 'acp/rooms'
	      redirect_to({ controller: 'rooms', action: 'edit', id: params[:room_id] }, notice: "Background được thêm thành công.")
	    else
				redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: @data.broadcaster.id, id: params[:room_id] }, notice: "Background được thêm thành công.")
	    end
		else
			flash[:create_background_alert] =  @data.errors.full_messages
			if prev_path[:controller] == 'acp/rooms'
      	redirect_to "/acp/rooms/#{params[:room_id]}/edit#modal-add-new-background"
	    else
      	redirect_to "/acp/broadcasters/#{@data.broadcaster.id}/room/#{params[:room_id]}#modal-add-new-background"
	    end
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
		prev_path = Rails.application.routes.recognize_path(request.referrer)
		@data.destroy
		if prev_path[:controller] == 'acp/rooms'
      redirect_to({ controller: 'rooms', action: 'edit', id: @data.broadcaster.rooms.find_by_is_privated(false) }, notice: "Background đã được xóa thành công.")
    else
			redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: @data.broadcaster.id }, notice: "Background đã được xóa thành công.")
    end
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