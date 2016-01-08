class BroadcasterLevel < ActiveRecord::Base
	validates :level, :min_heart, :grade, presence: true

	def next
		self.class.unscoped.where("level > ?", level).order("level ASC").first
	end
	def previous
		self.class.unscoped.where("level < ?", level).order("level ASC").last
	end
end
