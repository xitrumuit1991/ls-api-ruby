class Acp::BctVideosController < Acp::ApplicationController
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
    @data = @model.new(parameters)
    if @data.save
      redirect_to({ controller: 'broadcasters', action: 'videos', broadcaster_id: @data.broadcaster.id }, notice: 'Video was successfully created.')
    else
      flash[:create_video_alert] =  @data.errors.full_messages
      redirect_to "/acp/broadcasters/#{@data.broadcaster.id}/videos#modal-add-new"
    end
  end

  def update
    if @data.update(parameters)
      redirect_to({ action: 'index' }, notice: 'Video was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @data.destroy
    redirect_to({ controller: 'broadcasters', action: 'videos', broadcaster_id: @data.broadcaster.id }, notice: 'Video was successfully destroyed.')
  end

  def destroy_m
    @model.destroy(params[:item_id])
    redirect_to({ controller: 'broadcasters', action: 'videos', broadcaster_id: params[:broadcaster_id] }, notice: 'Videos was successfully destroyed.')
  end

  private
    def init
      @model = controller_name.classify.constantize
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:bct_video).permit(:broadcaster_id, :video, :thumb)
    end
end