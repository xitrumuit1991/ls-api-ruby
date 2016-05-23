class Acp::RolesController < Acp::ApplicationController
  load_and_authorize_resource
  before_filter :init
  before_action :load_data, only: [:new, :create, :edit, :update]
  before_action :set_data, only: [:show, :edit, :update, :destroy]

  def index
    @data = @model.all.order('weight asc')
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
      add_resources
      redirect_to({ action: 'index' }, notice: 'Role was successfully created.')
    else
      render :new
    end
  end

  def update
    if @data.update(parameters)
      add_resources
      redirect_to({ action: 'index' }, notice: 'Role was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @data.destroy
    redirect_to({ action: 'index' }, notice: 'Role was successfully destroyed.')
  end

  private
    def init
      @model = controller_name.classify.constantize
    end

    def load_data
      resources = Resource.all
      @permissions = Hash.new { |hash, key| hash[key] = [] }
      resources.each do |resource|
        if @permissions[resource.class_name.to_sym]
          @permissions[resource.class_name.to_sym].push resource
        else
          @permissions[resource.class_name.to_sym] = resource
        end
      end
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:data).permit(:name, :code, :description, :weight)
    end

    def add_resources
      @data.acls.destroy_all
      params[:resources].each do |id|
        @data.acls.create(resource_id: id)
      end
    end
end