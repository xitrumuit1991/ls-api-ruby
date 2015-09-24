class User < ActiveRecord::Base
  belongs_to :user_level
  has_one :broadcaster
  has_many :statuses

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
  validates_uniqueness_of :active_code
  has_secure_password
  mount_uploader :avatar, AvatarUploader
  mount_uploader :cover,  CoverUploader
end
