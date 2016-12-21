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

    order = params[:sort].present? ? "#{params[:field]} #{params[:sort]}" : "id desc"

  	@total = User.where(where).count
  	@users = params[:format].present? ? User.where(where).order(order) : User.where(where).order(order).page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def bct_time_logs
    @idols = Broadcaster.all.order('id desc').limit(1)
    where = Hash.new
    if params[:start_date].present? && params[:end_date].present?
      where[:created_at] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
    elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
      redirect_to({ action: 'bct_time_logs' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
    end
    where[:room_id] = params[:room] if params[:room].present?
    @data = BctTimeLog.all.where(where).order('id desc').page params[:page]
    @dataxlsx = BctTimeLog.all.where(where).order('id desc')
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def idol_autocomplete
    @idols = Broadcaster.where("fullname LIKE :query", query: "%#{params[:key]}%")
  end

  def mbf_users
    where = Hash.new
    where['created_at'] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

    if params[:start_date].present? && params[:end_date].present?
      where['created_at'] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
    elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
      redirect_to({ action: 'mbf_users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
    end

    order = params[:sort].present? ? "#{params[:field]} #{params[:sort]}" : "id desc"

    @total = MobifoneUser.where(where).count
    @users = params[:format].present? ? MobifoneUser.where(where).order(order) : MobifoneUser.where(where).order(order).page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def report_share
    where = Hash.new
    where[:created_at] = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
    if params[:broadcaster_id].present?
      where[:room_id] = Broadcaster.find_by_id(params[:broadcaster_id]).public_room.id if Broadcaster.find_by_id(params[:broadcaster_id]).public_room.present?
    end

    if params[:start_date].present? && params[:end_date].present?
      where[:created_at] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
    elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
      redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
    end
    @idols = Broadcaster.where(deleted: 0)
    order = params[:sort].present? ? "#{params[:field]} #{params[:sort]}" : "id desc"
    @data = params[:format].present? ? FbShareLog.select('room_id, COUNT(*) AS count').where(where).group(:room_id).order(order) : FbShareLog.select('room_id, COUNT(*) AS count').where(where).group(:room_id).order(order).page(params[:page])
    @dataxlsx = FbShareLog.select('room_id, COUNT(*) AS count').where(where).group(:room_id).order(order)
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

    order = params[:sort].present? ? "#{params[:field]} #{params[:sort]}" : "total desc"

  	@idols = Broadcaster.where(deleted: 0)
    @rooms = params[:format].present? ? Room.joins(:user_logs, broadcaster: :user).select("rooms.broadcaster_id, users.name, users.email, sum(user_logs.money) as total").where(where).order(order).group(:broadcaster_id) : Room.joins(:user_logs, broadcaster: :user).select("rooms.broadcaster_id, users.name, users.email, sum(user_logs.money) as total").where(where).order(order).group(:broadcaster_id).page(params[:page])
    @roomsxlsx = Room.joins(:user_logs, broadcaster: :user).select("rooms.broadcaster_id, users.name, users.email, sum(user_logs.money) as total").where(where).order(order).group(:broadcaster_id)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def idol_receive_hearts
  	where = Hash.new
  	where['heart_logs.created_at'] = Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

  	if params[:start_date].present? && params[:end_date].present?
  		where['heart_logs.created_at'] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
  	elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
  		redirect_to({ action: 'idol_receive_hearts' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
  	end

    order = params[:sort].present? ? "#{params[:field]} #{params[:sort]}" : "quantity desc"
    
    @rooms = params[:format].present? ? Room.joins(:heart_logs, broadcaster: :user).select("rooms.broadcaster_id, users.name, users.email, sum(heart_logs.quantity) as quantity").where(where).order(order).group(:broadcaster_id) : Room.joins(:heart_logs, broadcaster: :user).select("rooms.broadcaster_id, users.name, users.email, sum(heart_logs.quantity) as quantity").where(where).order(order).group(:broadcaster_id).page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def idol_gift_logs
    where = Hash.new
    where[:room_id] = params[:room_id].present? ? params[:room_id] : 0

    if params[:start_date].present? && params[:end_date].present?
      where[:created_at] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
    elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
      redirect_to({ action: 'idol_gift_logs' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
    end

    order = params[:sort].present? ? "#{params[:field]} #{params[:sort]}" : "created_at asc"

    @rooms = Room.where(is_privated: false)
    @all = GiftLog.where(where)
    @logs = @all.order(order).page(params[:page])
    @total = @all.to_a.sum(&:cost)
    @total_page = @logs.to_a.sum(&:cost)
  end

  def idol_action_logs
    where = Hash.new
    where[:room_id] = params[:room_id].present? ? params[:room_id] : 0

    if params[:start_date].present? && params[:end_date].present?
      where[:created_at] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
    elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
      redirect_to({ action: 'idol_gift_logs' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
    end

    order = params[:sort].present? ? "#{params[:field]} #{params[:sort]}" : "created_at asc"

    @rooms = Room.where(is_privated: false)
    @all = ActionLog.where(where)
    @logs = @all.order(order).page(params[:page])
    @total = @all.to_a.sum(&:cost)
    @total_page = @logs.to_a.sum(&:cost)
  end

  def idol_lounge_logs
    where = Hash.new
    where[:room_id] = params[:room_id].present? ? params[:room_id] : 0

    if params[:start_date].present? && params[:end_date].present?
      where[:created_at] = Time.parse(params[:start_date])..Time.parse(params[:end_date])
    elsif params[:start_date].present? && !params[:end_date].present? or !params[:start_date].present? && params[:end_date].present?
      redirect_to({ action: 'idol_gift_logs' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !') and return
    end

    order = params[:sort].present? ? "#{params[:field]} #{params[:sort]}" : "created_at asc"

    @rooms = Room.where(is_privated: false)
    @all = LoungeLog.where(where)
    @logs = @all.order(order).page(params[:page])
    @total = @all.to_a.sum(&:cost)
    @total_page = @logs.to_a.sum(&:cost)
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