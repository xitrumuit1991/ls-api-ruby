class BroadcasterLevel < ActiveRecord::Base
	def next
		self.class.unscoped.where("level > ?", level).order("level ASC").first
	end
	def previous
		self.class.unscoped.where("level < ?", level).order("level ASC").last
	end
end
