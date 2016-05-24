class User < ActiveRecord::Base
	belongs_to :user_level
	has_one :broadcaster
	has_one :mobifone_user
	has_many :statuses
	has_many :user_follow_bcts
	has_many :broadcasters, through: :user_follow_bcts
	has_many :screen_text_logs
	has_many :user_logs
	has_many :heart_logs
	has_many :action_logs
	has_many :gift_logs
	has_many :lounge_logs
	has_many :user_has_vip_packages
	has_many :vip_packages, through: :user_has_vip_packages
	has_many :otps
	has_many :trade_logs
	has_many :ban_users
	has_many :banned_rooms, through: :ban_users, class_name: 'Room', foreign_key: 'room_id', source: :room
	has_many :cart_logs
	has_many :megabank_logs
	has_many :android_receipts
	has_many :ios_receipts

	validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
	validates :username, presence: true, uniqueness: true, on: :update
	validates :name, presence: true, length: {minimum: 6, maximum: 150}, on: :update
	# validates :password, presence: true, length: {minimum: 8, maximum: 50}
	validates :phone, uniqueness: true, :allow_nil => true
	validates :active_code, uniqueness: true
	with_options({on: :auth}) do |for_auth|
		for_auth.validates :forgot_code, presence: true
	end
	has_secure_password
	mount_uploader :avatar, AvatarUploader
	mount_base64_uploader :avatar_crop, AvatarCropUploader
	mount_base64_uploader :cover_crop, CoverCropUploader
	mount_uploader :cover,  CoverUploader

	def ban room_id, days = 1, note = ''
		self.ban_users.create(room_id: room_id, days: days, note: note)
	end

	def is_banned room_id
		banned = self.ban_users.find_by_room_id(room_id)
		if banned.present?
			expiry_date = banned.created_at + banned.days.days
			return Time.now < expiry_date
		else
			return false
		end
	end

	def is_locking
		if self.locked_at.present?
			locked_time = Time.now - self.locked_at
			return locked_time <= 10.minutes
		else
			return false
		end
	end

	def login_fail
		if self.failed_at.present?
			failed_time = Time.now - self.failed_at
			if failed_time <= 10.minutes
				self.failed_attempts = self.failed_attempts + 1
				if self.failed_attempts >= 4
					self.locked_at = Time.now
				end
			else
				self.failed_attempts = 1
			end
		else
			self.failed_attempts = 1
		end
		self.failed_at = Time.now
		self.save
	end

	def public_room
		self.broadcaster.public_room
	end

	def avatar_path
		"#{Settings.base_url}/api/v1/users/#{self.id}/avatar?timestamp=#{self.updated_at.to_i}"
	end

	def cover_path
		"#{Settings.base_url}/api/v1/users/#{self.id}/cover?timestamp=#{self.updated_at.to_i}"
	end

	def horoscope
		arr = {
			"Aries"       =>  "Bạch Dương",
			"Taurus"      =>  "Kim Ngưu",
			"Gemini"      =>  "Song Tử",
			"Cancer"      =>  "Cự Giải",
			"Leo"         =>  "Sư Tử",
			"Virgo"       =>  "Thất Nữ",
			"Libra"       =>  "Thiên Xứng",
			"Scorpio"     =>  "Thiên Yết",
			"Sagittarius" =>  "Nhân Mã",
			"Capricornus" =>  "Ma Kết",
			"Aquarius"    =>  "Bảo Bình",
			"Pisces"      =>  "Song Ngư"
		}
		arr[self.birthday.zodiac_sign]
	end
	#check vip de su dung ham o authorize 
	def checkVip
		if self.user_has_vip_packages.count == 0
			return 0
		else
			if self.user_has_vip_packages.where('actived = ? AND expiry_date > ?', true, Time.now).present?
				return 1
			elsif self.user_has_vip_packages.where('actived = ? AND expiry_date < ?', true, Time.now).present?
				self.user_has_vip_packages.find_by_actived(true).update(actived: false)
				return 0
			else
				return 0
			end
		end
	end

	def increaseMoney(money)
		if money.to_i > 0
			old = self.money
			value = self.money + money
			self.update(money: value)
			NotificationChangeMoneyJob.perform_later(self.email, old, value)
		else
			raise "Số tiền không hợp lệ"
		end
	end

	def decreaseMoney(money)
		if self.money >= money then
			old = self.money
			value = self.money - money
			self.update(money: value)
			NotificationChangeMoneyJob.perform_later(self.email, old, value)
		else
			raise "Bạn không có đủ tiền"
		end
	end

	def increaseExp(exp)
		exp_bonus = self.checkVip == 1 ? self.user_has_vip_packages.find_by_actived(true).vip_package.vip.exp_bonus : 1
		old_value = self.user_exp
		new_value = (old_value + exp*exp_bonus) > 2147483647 ? old_value : old_value + exp*exp_bonus
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
