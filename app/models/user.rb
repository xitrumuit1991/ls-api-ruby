class User < ActiveRecord::Base
  belongs_to :user_level
  has_secure_password
  mount_uploader :avatar, AvatarUploader 
  validates_uniqueness_of :email
  validates_uniqueness_of :active_code
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
  after_create { sendActiveCode }

  private
  def sendActiveCode
    activeCode = SecureRandom.hex(3).upcase
    self.update_attributes active_code: activeCode
    SendCodeJob.perform_later(self, activeCode)
  end

end
