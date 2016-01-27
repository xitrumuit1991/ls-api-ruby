class SmsMobile < ActiveRecord::Base

	validates :price, :coin, presence: true
end
