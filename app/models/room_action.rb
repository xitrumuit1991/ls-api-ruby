class RoomAction < ActiveRecord::Base
  validates :name, :image, :price, :max_vote, :discount, presence: true

  mount_uploader :image,  RoomActionImageUploader
end
