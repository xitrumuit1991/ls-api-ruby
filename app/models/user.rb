class User < ActiveRecord::Base
  belongs_to :user_level
  has_secure_password
  mount_uploader :avatar, AvatarUploader 
  mount_uploader :cover,  CoverUploader 
  validates_uniqueness_of :email
  validates_uniqueness_of :active_code
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}

end
