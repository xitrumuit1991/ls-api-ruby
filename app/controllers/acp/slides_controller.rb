class Acp::SlidesController < Acp::ApplicationController
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
    parameters[:banner] = parameters[:banner].nil? ? parameters[:banner] : optimizeKraken(parameters[:banner])
    @data = @model.new(parameters)
    if @data.save
      redirect_to({ action: 'index' }, notice: 'Slide was successfully created.')
    else
      render :new
    end
  end

  def update
    parameters[:banner] = parameters[:banner].nil? ? parameters[:banner] : optimizeKraken(parameters[:banner])
    if @data.update(parameters)
      redirect_to({ action: 'index' }, notice: 'Slide was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @data.destroy
    redirect_to({ action: 'index' }, notice: 'Slide was successfully destroyed.')
  end

  def destroy_m
    @model.destroy(params[:item_id])
    redirect_to({ action: 'index' }, notice: 'Room featured were successfully destroyed.')
  end

  private
    def init
      @model = controller_name.classify.constantize
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:data).permit(:title, :description, :sub_description, :start_time, :weight, :link, :banner)
    end
end