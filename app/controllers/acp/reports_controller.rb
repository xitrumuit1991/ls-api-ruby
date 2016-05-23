class Acp::ReportsController < Acp::ApplicationController
  authorize_resource :class => false
  def index
  end

  def users
  	where = Hash.new
  	where['created_at'] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where['created_at'] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@total = User.where(where).count
  	@users = params[:format].present? ? User.where(where).order('id desc') : User.where(where).order('id desc').page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def user_online
  	where = Hash.new
  	where['last_login'] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where['last_login'] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@users = params[:format].present? ? User.where(where).order('id desc') : User.where(where).order('id desc').page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def user_send_gifts
  	where = Hash.new
  	where['created_at'] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where['created_at'] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@data = params[:format].present? ? GiftLog.select('user_id, sum(quantity) as quantity').where(where).group(:user_id).order('quantity DESC') : GiftLog.select('user_id, sum(quantity) as quantity').where(where).group(:user_id).order('quantity DESC').page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def user_send_hearts
  	where = Hash.new
  	where['created_at'] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where['created_at'] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@data = params[:format].present? ? HeartLog.select('user_id, sum(quantity) as quantity').where(where).group(:user_id).order('quantity DESC') : HeartLog.select('user_id, sum(quantity) as quantity').where(where).group(:user_id).order('quantity DESC').page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def idols
  	
  end

  def idol_receive_coins
  	where = Hash.new
  	where['rooms.broadcaster_id'] = params[:broadcaster_id] if params[:broadcaster_id].present?

  	if params[:start_date].present? && params[:end_date].present?
  		where['user_logs.created_at'] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'idol_receive_coins' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@idols = Broadcaster.where(deleted: 0)
		@rooms = params[:format].present? ? Room.joins(:user_logs).select("rooms.broadcaster_id, sum(user_logs.money) as total").where(where).group(:broadcaster_id) : Room.joins(:user_logs).select("rooms.broadcaster_id, sum(user_logs.money) as total").where(where).group(:broadcaster_id).page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def idol_receive_hearts
  	where = Hash.new
  	where['created_at'] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where['created_at'] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@data = params[:format].present? ? HeartLog.select('room_id, sum(quantity) as quantity').where(where).group(:room_id).order('quantity DESC') : HeartLog.select('room_id, sum(quantity) as quantity').where(where).group(:room_id).order('quantity DESC').page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def sms
  	where = Hash.new
  	where[:phone] = params[:phone] if params[:phone].present?
  	where[:created_at] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where[:created_at] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@total = SmsLog.select('sum(amount) as total').where(where).take
  	@data = params[:format].present? ? SmsLog.where(where) : SmsLog.where(where).page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def card
  	where = Hash.new
  	where_name = "users.name LIKE '%#{params[:name]}%'"
  	where[:created_at] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where[:created_at] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@total = CartLog.joins(:user).select('sum(price) as total').where(where).where(where_name).take
  	@data = params[:format].present? ? CartLog.joins(:user).where(where).where(where_name) : CartLog.joins(:user).where(where).where(where_name).page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def bank
  	where = Hash.new
  	where_name = "users.name LIKE '%#{params[:name]}%'"
  	where[:created_at] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where[:created_at] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

  	@total = MegabankLog.joins(:user, :megabank).select('sum(megabanks.price) as total').where(where).where("#{where_name} and responsecode = '00'").take
  	@data = params[:format].present? ? MegabankLog.joins(:user).where(where).where(where_name) : MegabankLog.joins(:user).where(where).where(where_name).page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

end