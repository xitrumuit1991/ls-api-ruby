class Coin < ActiveRecord::Base
	mount_uploader :image, CoinImageUploader
end
