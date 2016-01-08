class Gift < ActiveRecord::Base
  validates :name, :image, :price, :discount, presence: true

  mount_uploader :image,  GiftImageUploader
end
