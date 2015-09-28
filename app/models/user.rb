class User < ActiveRecord::Base
	belongs_to :user_level
	has_one :broadcaster
	has_many :statuses
	has_many :user_follow_bcts

	validates :username, presence: true, uniqueness: true
	validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
	validates_uniqueness_of :active_code
	has_secure_password
	mount_uploader :avatar, AvatarUploader
	mount_uploader :cover,  CoverUploader

	def decreaseMoney(money)
		if self.money >= money then
			value = self.money - money
			self.update(money: value)
		else
			raise "You don\'t have enough money"
		end
	end

	def increaseExp(exp)
		new_value = self.user_exp + exp
		next_level = UserLevel.where("min_exp <= ?", new_value).last
		self.user_exp = new_value
		if new_value >= next_level.min_exp then
			self.user_level = next_level
		end
		self.save
	end

end
