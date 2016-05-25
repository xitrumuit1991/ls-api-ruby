require 'roo'
class Acp::IndexController < Acp::ApplicationController

	def index
	end

	def import
		file = Roo::Excelx.new("#{Rails.root}/public/default/Danh sach account CSKH DV GTGT tong hop 0304 2015.xlsx")

		(1..file.last_row).each do |i|
  		row = file.row(i)
  		admin = Admin.new
			admin.role_id = 2
	    admin.email 	= "#{row[0]}@mobifone.com.vn"
	    admin.password 							= row[1]
	    admin.password_confirmation = row[1]
  		admin.save
		end

		(1..file.sheet(1).last_row).each do |i|
  		row = file.row(i)
  		admin = Admin.new
			admin.role_id = 2
	    admin.email 	= "#{row[0]}@mobifone.com.vn"
	    admin.password 							= row[1]
	    admin.password_confirmation = row[1]
  		admin.save
		end
		redirect_to "/acp"
	end

end