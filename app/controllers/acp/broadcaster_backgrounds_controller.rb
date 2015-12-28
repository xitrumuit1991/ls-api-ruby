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
			redirect_to({ controller: 'broadcasters', action: 'room', broadcaster_id: @data.broadcaster.id, id: @data.id }, notice: 'Background was successfully created.')
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