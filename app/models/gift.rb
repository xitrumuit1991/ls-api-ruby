class Gift < ActiveRecord::Base
  validates :name, :image, :price, :discount, presence: true
  validates :price, :discount, numericality: { only_integer: true }

  mount_uploader :image,  GiftImageUploader
end
