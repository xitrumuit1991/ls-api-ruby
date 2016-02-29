class Acp::GiftsController < Acp::ApplicationController
  before_filter :init
  before_action :set_data, only: [:show, :edit, :update, :destroy, :ajax_update_handle_checkbox]

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
      redirect_to({ action: 'index' }, notice: 'Room type was successfully created.')
    else
      render :new
    end
  end

  def update
    if @data.update(parameters)
      redirect_to({ action: 'index' }, notice: 'Gift was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @data.destroy
    redirect_to({ action: 'index' }, notice: 'Gift was successfully destroyed.')
  end

  def ajax_update_handle_checkbox
    if @data.update(params[:attrs].to_hash)
      render plain: 'Success', status: 200
    else
      render plain: 'Error', status: 400
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
      params.require(:data).permit(:name, :image, :price, :discount)
    end
end