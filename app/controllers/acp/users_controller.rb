class Acp::UsersController < Acp::ApplicationController
  load_and_authorize_resource
  before_filter :init
  before_action :load_data, only: [:new, :create, :edit, :update]
  before_action :set_data, only: [:show, :edit, :update, :transactions, :change_password, :destroy, :history_vips, :history_buy_coins, :history_use_coins]

  def index
    where = Hash.new
    where[:deleted] = 0
    where[:created_at] = Date.parse(params[:date]).beginning_of_day..Date.parse(params[:date]).end_of_day if params[:date].present?
    where_like = "#{params[:field]} LIKE '%#{params[:q]}%'" if params[:field].present?
    @data = @model.all.where(where).where(where_like).order('id desc').page params[:page]
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
    @data.password = params[:password]
    @data.password_confirmation = params[:password_confirmation]
    @data.active_code = SecureRandom.hex(3).upcase

    if params[:actived].present?
      @data.active_date = Time.now
      @data.actived = 1
    end

    if @data.save
      redirect_to({ action: 'index' }, notice: 'User was successfully created.')
    else
      render :new
    end
  end

  def update
    prev_path = Rails.application.routes.recognize_path(request.referrer)
    @data.actived = params[:actived].nil? ? 0 : params[:actived]

    if @data.update(parameters)
      if prev_path[:controller] == 'acp/users'
        redirect_to({ action: 'index' }, notice: "Thông tin tài khoản '#{@data.username}' được cập nhật thành công.")
      else
        redirect_to({ controller: 'broadcasters', action: 'basic', broadcaster_id: @data.broadcaster.id, id: @data.id }, notice: 'Thông tin cơ bản được cập nhật thành công.')
      end
    else
      if prev_path[:controller] == 'acp/users'
        render :edit
      else
        redirect_to({ controller: 'broadcasters', action: 'basic', broadcaster_id: @data.broadcaster.id, id: @data.id }, alert: @data.errors.full_messages)
      end
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
      flash[:change_password_alert] =  @data.errors.full_messages
      if prev_path[:controller] == 'acp/users'
        redirect_to "/acp/users/#{@data.id}/edit#modal-change-password"
      else
        redirect_to "/acp/broadcasters/#{@data.broadcaster.id}/basic/#{@data.id}#modal-change-password"
      end
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

  def history_vips
    where = Hash.new
    where[:active_date] = Date.parse(params[:date]).beginning_of_day..Date.parse(params[:date]).end_of_day if params[:date].present?
    @logs = @data.user_has_vip_packages.where(where).order('id desc').page params[:page]
  end

  def history_buy_coins
    where_sms = Hash.new
    where_sms[:active_code] = @data.active_code
    where_sms[:created_at] = Date.parse(params[:date_sms]).beginning_of_day..Date.parse(params[:date_sms]).end_of_day if params[:date_sms].present?
    @sms = SmsLog.where(where_sms).order('id desc').page params[:page]

    where_card = Hash.new
    where_card[:created_at] = Date.parse(params[:date_card]).beginning_of_day..Date.parse(params[:date_card]).end_of_day if params[:date_card].present?
    @cards = @data.cart_logs.where(where_card).order('id desc').page params[:page]

    where_bank = Hash.new
    where_bank[:created_at] = Date.parse(params[:date_bank]).beginning_of_day..Date.parse(params[:date_bank]).end_of_day if params[:date_bank].present?
    @banks = @data.megabank_logs.where(where_bank).order('id desc').page params[:page]

    where_ios = Hash.new
    where_ios['ios_receipts.user_id'] = @data.id
    where_ios['ios_receipts.created_at'] = Date.parse(params[:date_ios]).beginning_of_day..Date.parse(params[:date_ios]).end_of_day if params[:date_ios].present?
    # @ios = @data.ios_receipts.where(where_ios).order('id desc').page params[:page]
    @ios = IosReceipt.select('ios_receipts.created_at, coins.name, coins.price, coins.price_usd, coins.quantity').joins('join coins on ios_receipts.product_id = coins.code').where(where_ios).order('ios_receipts.id desc').page params[:page]

    where_android = Hash.new
    where_android['android_receipts.user_id'] = @data.id
    where_android['android_receipts.created_at'] = Date.parse(params[:date_android]).beginning_of_day..Date.parse(params[:date_android]).end_of_day if params[:date_android].present?
    # @android = @data.android_receipts.where(where_android).order('id desc').page params[:page]
    @android = AndroidReceipt.select('android_receipts.created_at, coins.name, coins.price, coins.price_usd, coins.quantity').joins('join coins on android_receipts.productId = coins.code').where(where_android).order('android_receipts.id desc').page params[:page]
  end

  def history_use_coins
    where_gift = Hash.new
    where_gift[:created_at] = Date.parse(params[:date_gift]).beginning_of_day..Date.parse(params[:date_gift]).end_of_day if params[:date_gift].present?
    @gifts = @data.gift_logs.where(where_gift).order('id desc').page params[:page]

    where_action = Hash.new
    where_action[:created_at] = Date.parse(params[:date_action]).beginning_of_day..Date.parse(params[:date_action]).end_of_day if params[:date_action].present?
    @actions = @data.action_logs.where(where_action).order('id desc').page params[:page]

    where_messages = Hash.new
    where_messages[:created_at] = Date.parse(params[:date_message]).beginning_of_day..Date.parse(params[:date_message]).end_of_day if params[:date_message].present?
    @messages = @data.screen_text_logs.where(where_messages).order('id desc').page params[:page]
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
      params.require(:user).permit(:username, :name, :email, :user_level_id, :user_exp)
    end
end