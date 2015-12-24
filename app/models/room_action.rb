class RoomAction < ActiveRecord::Base
  validates :name, :price, :max_vote, :discount, presence: true
  validates :price, :max_vote, :discount, numericality: { only_integer: true }

  mount_uploader :image,  RoomActionImageUploader
end
