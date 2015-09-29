class Gift < ActiveRecord::Base
  mount_uploader :image,  GiftImageUploader
end
