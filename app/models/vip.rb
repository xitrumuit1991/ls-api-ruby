class Vip < ActiveRecord::Base
	has_many :vip_packages
	validates :name, :code, :image, :weight, :no_char, :screen_text_time, :screen_text_effect, :kick_level, :clock_kick, :exp_bonus, presence: true

	mount_uploader :image,  VipImageUploader

	def priceVip(day)
		return self.vip_packages.where(no_day: day).take.price
	end
end
