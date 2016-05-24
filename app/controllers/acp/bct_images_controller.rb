class Acp::BctImagesController < Acp::ApplicationController
  include KrakenHelper
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
    parameters[:image] = parameters[:image].nil? ? parameters[:image] : optimizeKraken(parameters[:image])
    @data = @model.new(parameters)
    if @data.save
      redirect_to({ controller: 'broadcasters', action: 'images', broadcaster_id: @data.broadcaster.id }, notice: 'Image was successfully created.')
    else
      redirect_to({ controller: 'broadcasters', action: 'images', broadcaster_id: @data.broadcaster.id }, alert: @data.errors.full_messages)
    end
  end

  def update
    parameters[:image] = parameters[:image].nil? ? parameters[:image] : optimizeKraken(parameters[:image])
    if @data.update(parameters)
      redirect_to({ action: 'index' }, notice: 'Image was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @data.destroy
    redirect_to({ controller: 'broadcasters', action: 'images', broadcaster_id: @data.broadcaster.id }, notice: 'Image was successfully destroyed.')
  end

  def destroy_m
    @model.destroy(params[:item_id])
    redirect_to({ controller: 'broadcasters', action: 'images', broadcaster_id: params[:broadcaster_id] }, notice: 'Images was successfully destroyed.')
  end

  private
    def init
      @model = controller_name.classify.constantize
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:bct_image).permit(:broadcaster_id, :image)
    end
end