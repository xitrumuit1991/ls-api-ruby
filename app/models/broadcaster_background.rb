class BroadcasterBackground < ActiveRecord::Base
  belongs_to :broadcaster
  has_many :rooms

  mount_uploader :image, BroadcasterBackgroundUploader

	validates :image, presence: true
end
