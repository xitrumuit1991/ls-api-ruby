class BctImage < ActiveRecord::Base
  belongs_to :broadcaster

  mount_uploader :image, PictureUploader

	validates :image, presence: true
end
