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

  def test
    @data = @model.all.order('weight asc')
    puts '==============='
    puts controller_name
    puts controller_name.classify.constantize
    puts "roles".classify.constantize
    puts '==============='
    # authorize! :test, Role
  end

  def new
    @data = @model.new



    # Acp::RolesController.action_methods.each do |action|
    #   puts '==================='
    #   puts action
    # end

    # controller = "Acp::UsersController".classify.constantize
    # controller.action_methods.each do |action|
    #   puts '===================123456'
    #   puts action
    # end

    
    controllers = Dir.new("#{Rails.root}/app/controllers/acp").entries
    controllers.each do |controller|
      if controller =~ /_controller/
        foo_bar = "Acp::#{controller.camelize.gsub(".rb","")}".classify.constantize
        puts '==================='
        puts foo_bar.controller_name
        # foo_bar.action_methods.each do |action|
        #   puts '==================='
        #   puts action
        # end
      end
    end
    puts '==================='


  end

  def edit
  end

  def create
    @data = @model.new(parameters)
    if @data.save
      redirect_to({ action: 'index' }, notice: 'Role was successfully created.')
    else
      render :new
    end
  end

  def update
    puts '=============='
    puts params
    puts '=============='
    if @data.update(parameters)
      @data.acls.create(resource_id: [1,2])
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
      @resources = Resource.all
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:data).permit(:name, :code, :description, :weight)
    end
end