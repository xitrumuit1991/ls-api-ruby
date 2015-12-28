class Acp::SchedulesController < Acp::ApplicationController
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
			start_time = DateTime.parse(item['date_start'] + ' ' + item['time_start'])
			end_time = DateTime.parse(item['date_end'] + ' ' + item['time_end'])
			@model.create(start: start_time, end: end_time, room_id: params[:room_id])
		end
		redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: params[:broadcaster_id], id: params[:room_id] }, notice: 'Schedules was successfully created.')
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
		redirect_to({ action: 'index' }, notice: 'Schedule was successfully destroyed.')
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