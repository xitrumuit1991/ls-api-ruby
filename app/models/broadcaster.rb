class Broadcaster < ActiveRecord::Base
	belongs_to :user
	belongs_to :bct_type
	belongs_to :broadcaster_level
	has_many :images, class_name:'BctImage'
	has_many :videos, class_name:'BctVideo'

	def increaseExp(exp)
		new_value = self.broadcaster_exp + exp
		next_level = BroadcasterLevel.where("min_heart <= ?", new_value).last
		self.broadcaster_exp = new_value
		if new_value >= next_level.min_heart then
			self.broadcaster_level = next_level
		end
		self.save
	end
end
