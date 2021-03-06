class Acp::AdminsController < Acp::ApplicationController
  load_and_authorize_resource
  before_filter :init
  before_action :load_data, only: [:new, :create, :edit, :update]
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

  private
    def init
      @model = controller_name.classify.constantize
    end

    def load_data
      @roles = Role.all
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:data).permit(:email, :role_id, :password, :password_confirmation)
    end
end