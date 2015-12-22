class UserLevel < ActiveRecord::Base
	validates :level, :min_exp, :heart_per_day, :grade, presence: true
	validates :level, :min_exp, :heart_per_day, :grade, numericality: { only_integer: true }

	def next
		self.class.unscoped.where("level > ?", level).order("level ASC").first
	end

	def previous
		self.class.unscoped.where("level < ?", level).order("level ASC").last
	end
end
