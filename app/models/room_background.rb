class RoomBackground < ActiveRecord::Base
	has_many :rooms

	validates :image,  presence: true

	mount_uploader :image, RoomBackgroundUploader
end
