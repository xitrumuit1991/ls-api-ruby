class Gift < ActiveRecord::Base
  has_many :bct_gifts
  validates :name, :image, :price, :discount, presence: true

  mount_uploader :image,  GiftImageUploader
end
