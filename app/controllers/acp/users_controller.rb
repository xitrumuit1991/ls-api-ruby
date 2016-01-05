class Acp::UsersController < Acp::ApplicationController
  before_filter :init
  before_action :load_data, only: [:new, :create, :edit, :update]
  before_action :set_data, only: [:show, :edit, :update, :transactions, :change_password, :destroy]

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

  def transactions
    @gifts = @data.gift_logs.order('id desc')
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
    prev_path = Rails.application.routes.recognize_path(request.referrer)
    if @data.update(parameters)
      if prev_path[:controller] == 'acp/users'
        redirect_to({ action: 'index' }, notice: "Thông tin tài khoản '#{@data.username}' được cập nhật thành công.")
      else
        redirect_to({ controller: 'broadcasters', action: 'basic', broadcaster_id: @data.broadcaster.id, id: @data.id }, notice: 'Thông tin cơ bản được cập nhật thành công.')
      end
    else
      render :edit
    end
  end

  def change_password
    prev_path = Rails.application.routes.recognize_path(request.referrer)
    if @data.update(password: params[:password], password_confirmation: params[:password_confirmation])
      if prev_path[:controller] == 'acp/users'
        redirect_to({ action: 'edit', id: @data.id }, notice: "Đổi mật khẩu thành công.")
      else
        redirect_to({ controller: 'broadcasters', action: 'basic', broadcaster_id: @data.broadcaster.id, id: @data.id }, notice: 'Đổi mật khẩu thành công.')
      end
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
    redirect_to({ action: 'index' }, notice: 'Users were successfully destroyed.')
  end

  private
    def init
      @model = controller_name.classify.constantize
    end

    def load_data
      @levels = UserLevel.all
    end

    def set_data
      @data = @model.find(params[:id])
    end

    def parameters
      params.require(:user).permit(:username, :name, :user_level_id, :user_exp)
    end
end