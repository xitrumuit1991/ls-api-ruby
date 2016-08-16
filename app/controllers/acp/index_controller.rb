require 'roo'
class Acp::IndexController < Acp::ApplicationController

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

	def script
		User.where("is_banned IS NULL").update_all(is_banned: 0)
		redirect_to "/acp"
	end

end