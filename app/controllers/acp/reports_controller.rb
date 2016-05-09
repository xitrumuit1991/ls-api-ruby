class Acp::ReportsController < Acp::ApplicationController

  def index
  end

  def users
  	if defined? params[:start_date]
  		puts 'aaaaaaaaaa'
  	else
  		puts 'bbbbbbbbbb'
  	end

  	if !params[:start_date].present? && !params[:end_date].present?
  		puts '1111111111'
  		where = "created_at >= '#{Time.zone.now.beginning_of_day}'"
  	elsif params[:start_date].present? && !params[:start_date].empty? && params[:end_date].present? && !params[:end_date].empty?
  		puts '2222222222'
  		where = "created_at between '#{params[:start_date]}'' and '#{params[:end_date]}'"
  	else
  		puts '3333333333'
  		redirect_to({ action: 'users' }, alert: 'Vui lòng chọn ngày bắt đầu và ngày kết thúc !')
  	end

  	if params[:start_date].present? && params[:end_date].present?
  		where = "created_at between '#{params[:start_date]}'' and '#{params[:end_date]}'"
  	elsif params[:start_date].present? && params[:end_date].present?
  			
  	else
  		where = "created_at >= '#{Time.zone.now.beginning_of_day}'"
  	end
  			

  	if params[:format].present? && params[:format] == 'xlxs'
  		@users = User.all.where(where).order('id desc')
  	else
  		@users = User.all.where(where).order('id desc').page params[:page]
  	end
  	puts '============'
  	puts params
  	puts '============'
    respond_to do |format|
      format.html
      format.xlsx
    end
    # render xlsx: "reports/users"
    # render "acp/reports/users.xlsx.axlsx"
    # render :xlsx => "users", template: "acp/reports/users"
    # render :xlsx => "users", :filename => "all_users.xlsx"
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
		@rooms = params[:format].present? && params[:format] == 'xlxs' ? Room.joins(:user_logs).where(where) : Room.joins(:user_logs).select("rooms.broadcaster_id, sum(user_logs.money) as total").where(where).group(:broadcaster_id).page(params[:page])
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

end