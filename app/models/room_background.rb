class RoomBackground < ActiveRecord::Base
	has_many :rooms

	mount_uploader :image, RoomBackgroundUploader
end
