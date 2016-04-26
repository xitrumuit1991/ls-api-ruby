class RoomAction < ActiveRecord::Base
  belongs_to :bct_actions
  validates :name, :image, :price, :max_vote, :discount, presence: true

  mount_uploader :image,  RoomActionImageUploader
end
