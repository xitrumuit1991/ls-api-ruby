class User < ActiveRecord::Base
	belongs_to :user_level
	has_one :broadcaster
	has_many :statuses
	has_many :user_follow_bcts
	has_many :broadcasters, through: :user_follow_bcts
	has_many :screen_text_logs
	has_many :heart_logs
	has_many :action_logs
	has_many :gift_logs
	has_many :lounge_logs

	validates :username, presence: true, uniqueness: true
	validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
	validates_uniqueness_of :active_code
	has_secure_password
	mount_uploader :avatar, AvatarUploader
	mount_uploader :avatar_crop, AvatarCropUploader
	mount_uploader :cover,  CoverUploader

	def public_room
		self.broadcaster.rooms.find_by_is_privated(false)
	end

	def decreaseMoney(money)
		if self.money >= money then
			old = self.money
			value = self.money - money
			self.update(money: value)
			NotificationChangeMoneyJob.perform_later(self.email, old, value)
		else
			raise "You don\'t have enough money"
		end
	end

	def increaseExp(exp)
		old_value = self.user_exp
		new_value = old_value + exp
		self.user_exp = new_value
		next_level = UserLevel.where("min_exp <= ?", new_value).last
		#next_level = self.user_level.next
		percent = self.percent
		if next_level
			if self.user_level.level < next_level.level then
				self.user_level = next_level
				if next_level.next
					all = next_level.next.min_exp - next_level.min_exp
					percent = (new_value - next_level.min_exp) * 100 / all
				else
					percent = 100
				end
				NotificationLevelUpJob.perform_later(self.email, self.user_level.level)
			end
		end
		self.save
		NotificationChangeExpJob.perform_later(self.email, old_value, new_value, percent)
	end

	def percent
		percent = 0

		if user_level.next
			all = user_level.next.min_exp - user_level.min_exp
			curent = user_exp - user_level.min_exp
			percent = curent * 100 / all
		else
			percent = 100
		end
		return percent
	end

end
