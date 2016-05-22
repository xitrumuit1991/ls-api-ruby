class Acp::SchedulesController < Acp::ApplicationController
	load_and_authorize_resource
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
		params[:schedule].each do |item|
			next if item['date_start'] == '' || item['date_end'] == '' || item['time_start'] == '' || item['time_end'] == ''
			start_time = DateTime.parse(item['date_start'] + ' ' + item['time_start'])
			end_time = DateTime.parse(item['date_end'] + ' ' + item['time_end'])
			@model.create(start: start_time, end: end_time, room_id: params[:room_id])
		end

    prev_path = Rails.application.routes.recognize_path(request.referrer)
    if prev_path[:controller] == 'acp/rooms'
      redirect_to({ controller: 'rooms', action: 'edit', id: params[:room_id] }, notice: "Lịch diển đã được thêm thành công.")
    else
			redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: params[:broadcaster_id], id: params[:room_id] }, notice: 'Lịch diển đã được thêm thành công.')
    end
	end

	def update
		if @data.update(parameters)
			redirect_to({ action: 'index' }, notice: 'Schedule was successfully updated.')
		else
			render :edit
		end
	end

	def destroy
		@data.destroy
		prev_path = Rails.application.routes.recognize_path(request.referrer)
    if prev_path[:controller] == 'acp/rooms'
      redirect_to({ controller: 'rooms', action: 'edit', id: @data.room.id }, notice: "Lịch diển đã được xóa thành công.")
    else
			redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: @data.room.broadcaster.id, id: @data.room.id }, notice: "Lịch diển đã được xóa thành công.")
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
			params.require(:schedule).permit(:start, :end)
		end
end