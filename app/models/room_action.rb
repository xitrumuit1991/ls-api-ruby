class RoomAction < ActiveRecord::Base
  mount_uploader :image,  RoomActionImageUploader
end
