class Vip < ActiveRecord::Base
	has_many :vip_packages
	validates :name, :code, :image, :weight, :no_char, :screen_text_time, :screen_text_effect, :kick_level, :clock_kick, :exp_bonus, presence: true

	mount_uploader :image,  VipImageUploader

	def priceVip(day)
		Rails.logger.info "ANGCO DEBUG vip_packages: #{self.vip_packages.where(no_day: day).take.nil?}"
		if self.vip_packages.where('code != ? and code != ? and code != ? and code != ? and code != ? and code != ? and no_day = ?', "VIP1", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4", day).take.nil?
			return false 
		else
			return self.vip_packages.where('code != ? and code != ? and code != ? and code != ? and code != ? and code != ? and no_day = ?', "VIP1", "VIP7", "VIP30", "VIP2", "VIP3", "VIP4", day).take
		end
	end
end
