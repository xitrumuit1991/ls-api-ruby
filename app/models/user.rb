class User < ActiveRecord::Base
  belongs_to :user_level
  has_secure_password
  mount_uploader :avatar, AvatarUploader 
end
