class Acp::ResourcesController < Acp::ApplicationController
  # load_and_authorize_resource
  before_filter :init
  before_action :set_data, only: [:show, :edit, :update, :destroy]

  def index
    @data = @model.all
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

  def sync
    write_resource("Manage All", "Manage All", "all", "all", "manage")
    controllers = Dir.new("#{Rails.root}/app/controllers/acp").entries
    controllers.each do |controller|
      if controller =~ /_controller/
        clazz = "Acp::#{controller.camelize.gsub(".rb","")}".classify.constantize
        next if clazz.controller_name == 'application'
        clazz.action_methods.each do |action|
          name = action
          description = action
          class_name = clazz.controller_name.classify
          action_name = action
          can = eval_cancan_action(action)
          write_resource(name, description, class_name, action_name, can)
        end
      end
    end
    redirect_to({ action: 'index' }, notice: 'Resources were successfully updated.')
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

    def eval_cancan_action(action)
      cancan_action = case action.to_s
        when "index", "show"
          cancan_action = "read"
        when "new", "create"
          cancan_action = "create"
        when "edit", "update"
          cancan_action = "update"
        when "destroy"
          cancan_action = "delete"
        else
          cancan_action = action.to_s
      end
    end

    def write_resource(name, description, class_name, action_name, can)
      resource  = Resource.find_by(class_name: class_name, action_name: action_name)
      if not resource
        resource = Resource.new
        resource.name = name
        resource.description =  description
        resource.class_name = class_name
        resource.action_name = action_name
        resource.can = can
        resource.save
      end
    end
end