class Acp::UsersController < Acp::ApplicationController
  before_filter :init
  before_action :set_data, only: [:show, :edit, :update, :change_password, :destroy]

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
      redirect_to({ action: 'index' }, notice: 'User was successfully created.')
    else
      render :new
    end
  end

  def update
    if @data.update(parameters)
      redirect_to({ controller: 'broadcasters', action: 'basic', broadcaster_id: @data.broadcaster.id, id: @data.id }, notice: 'User was successfully created.')
    else
      render :edit
    end
  end

  def change_password
    if @data.update(password: params[:password], password_confirmation: params[:password_confirmation])
      redirect_to({ controller: 'broadcasters', action: 'basic', broadcaster_id: @data.broadcaster.id, id: @data.id }, notice: 'Change password success.')
    else
      render :edit
    end
  end

  def destroy
    @data.destroy
    redirect_to({ action: 'index' }, notice: 'User was successfully destroyed.')
  end

  def destroy_m
    @model.destroy(params[:item_id])
    redirect_to({ action: 'index' }, notice: 'User were successfully destroyed.')
  end

  private
    def init
      @model = controller_name.classify.constantize
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:user).permit(:username, :name, :user_level_id, :user_exp)
    end
end