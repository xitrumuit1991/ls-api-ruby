class Acp::NotificationsController < Acp::ApplicationController
  load_and_authorize_resource
  before_filter :init
  before_action :load_data, only: [:new]
  before_action :set_data, only: [:show, :destroy]

  def index
    @data = @model.all.order('id desc')
  end

  def show

  end

  def new
    @data = @model.new
  end

  def create
    @data = @model.new(parameters)
    if @data.save
      deviceToken = DeviceToken::all
      list_ios_tokens = []
      list_android_tokens = []
      deviceToken.each do |device|
        if device.device_type == 'ios'
          list_ios_tokens.push(device.device_token)
        elsif device.device_type == 'android'
          list_android_tokens.push(device.device_token)
        end
      end
      DeviceNotificationJob.perform_later(params[:room_id], params[:title], params[:description], list_ios_tokens, list_android_tokens)
      redirect_to({ action: 'index' }, notice: 'Home featured was successfully created.')
    else
      render :new
    end
  end

  def update
    if @data.update(parameters)
      redirect_to({ action: 'index' }, notice: 'Home featured was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @data.destroy
    redirect_to({ action: 'index' }, notice: 'Home featured was successfully destroyed.')
  end

  def destroy_m
    @model.destroy(params[:item_id])
    redirect_to({ action: 'index' }, notice: 'Home featured were successfully destroyed.')
  end

  private
    def init
      @model = controller_name.classify.constantize
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def load_data
      @rooms = Room.all.order('id desc')
    end

    def parameters
      params.require(:data).permit(:title, :description, :status, :room_id, :admin_id)
    end
end