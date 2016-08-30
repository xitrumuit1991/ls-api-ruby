require 'roo'
class Acp::IndexController < Acp::ApplicationController
	include Api::V1::Vas

	def index
	end

	def import
		file = Roo::CSV.new("#{Rails.root}/public/default/IP_pool_updated_20160517.csv")

		(1..file.last_row).each do |i|
			row = file.row(i)
			mbf_ip = MobifoneIp.new
			mbf_ip.ip = row[0]
			mbf_ip.save
		end

		redirect_to "/acp"
	end

	def importBlackList
		file = Roo::CSV.new("#{Rails.root}/public/default/livestar-mbf.csv")
		(1..file.last_row).each do |i|
			row = file.row(i)
			mbf_ip = MobifoneBlacklist.new
			mbf_ip.sub_id = row[0]
			mbf_ip.save
		end
		redirect_to "/acp"
	end

	def importEmailBlackList
		file = Roo::CSV.new("#{Rails.root}/public/default/email-blacklist.csv")
		(1..file.last_row).each do |i|
			row = file.row(i)
			email_domain = EmailDomainBlacklist.new
			email_domain.domain = row[0]
			email_domain.save
		end
		redirect_to "/acp"
	end

	def script
		User.where("is_banned IS NULL").update_all(is_banned: 0)
		redirect_to "/acp"
	end

	def vas_delete_sub_id
		result = vas_delete_sub params[:sub]
    render plain: result, status: 200
	end

end