class Acp::PostersController < Acp::ApplicationController
  include KrakenHelper
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
    parameters[:thumb] = optimizeKraken(parameters[:thumb])
    @data = @model.new(parameters)
    if @data.save
      redirect_to({ action: 'index' }, notice: 'Poster was successfully created.')
    else
      render :new
    end
  end

  def update
    parameters[:thumb] = optimizeKraken(parameters[:thumb])
    if @data.update(parameters)
      redirect_to({ action: 'index' }, notice: 'Poster was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @data.destroy
    redirect_to({ action: 'index' }, notice: 'Poster was successfully destroyed.')
  end

  private
    def init
      @model = controller_name.classify.constantize
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:data).permit(:title, :sub_title, :thumb, :link, :weight)
    end
end