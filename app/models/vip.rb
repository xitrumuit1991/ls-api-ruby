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

	def image_path
		image = {}
		if !self.image.url.nil?
			image = {
					image: 		"#{Settings.base_url}#{self.image.url}", 
					image_w60h60: 	"#{Settings.base_url}#{self.image.w60h60.url}",
					image_w100h100: 	"#{Settings.base_url}#{self.image.w100h100.url}",
					image_w120h120: 	"#{Settings.base_url}#{self.image.w120h120.url}",
					image_w200h200: 	"#{Settings.base_url}#{self.image.w200h200.url}",
					image_w240h240: 	"#{Settings.base_url}#{self.image.w240h240.url}",
					image_w300h300: 	"#{Settings.base_url}#{self.image.w300h300.url}",
					image_w400h400: 	"#{Settings.base_url}#{self.image.w400h400.url}",
				}
		else
			image = {
					image: 				nil,
					image_w60h60: 		nil,
					image_w100h100: 	nil,
					image_w120h120: 	nil,
					image_w200h200: 	nil,
					image_w240h240: 	nil,
					image_w300h300: 	nil,
					image_w400h400: 	nil,
				}
		end
		return image
		# "#{Settings.base_url}/api/v1/users/#{self.id}/avatar?timestamp=#{self.updated_at.to_i}"
	end
end
