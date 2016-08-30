class Broadcaster < ActiveRecord::Base
	belongs_to :user
	belongs_to :bct_type
	belongs_to :broadcaster_level

	has_many :user_follow_bcts
	has_many :users, through: :user_follow_bcts

	has_many :rooms
	has_many :broadcaster_backgrounds
	has_many :images, class_name:'BctImage'
	has_many :videos, -> { order('video_type DESC, id DESC') }, class_name:'BctVideo'

	validates :user_id, :bct_type_id, :broadcaster_level_id, :fullname, presence: true
	validates :broadcaster_exp, :recived_heart, numericality: { only_integer: true }

	def public_room
		self.rooms.find_by_is_privated(false)
	end

	def increaseExp(exp)
		old_value = self.broadcaster_exp
		new_value = (old_value + exp) > 2147483647 ? old_value : old_value + exp
		self.broadcaster_exp = new_value
		# next_level = UserLevel.where("min_heart <= ?", new_value).last
		next_level = self.broadcaster_level.next
		percent = self.percent
		isLevelUp = false
		if next_level
			if new_value >= next_level.min_heart then
				isLevelUp = true
				self.broadcaster_level = next_level
				if next_level.next
					all = next_level.next.min_heart - next_level.min_heart
					percent = (new_value - next_level.min_heart) * 100 / all
				else
					percent = 100
				end
			end
		end
		self.save
		self.rooms.each do |room|
			if isLevelUp
				NotificationBctLevelUpJob.perform_later(room.id, self.broadcaster_level.level)
			end
			NotificationChangeBctExpJob.perform_later(room.id, old_value, new_value, percent)
		end
	end

	def percent
		percent = 0

		if broadcaster_level.next
			all = broadcaster_level.next.min_heart - broadcaster_level.min_heart
			curent = broadcaster_exp - broadcaster_level.min_heart
			percent = curent * 100 / all
		else
			percent = 100
		end
		return percent
	end
end
