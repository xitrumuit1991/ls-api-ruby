class Vip < ActiveRecord::Base
	validates :name, :code, :image, :weight, :no_char, :screen_text_time, :screen_text_effect, :kick_level, :clock_kick, :clock_ads, :exp_bonus, presence: true

	mount_uploader :image,  VipImageUploader
end
